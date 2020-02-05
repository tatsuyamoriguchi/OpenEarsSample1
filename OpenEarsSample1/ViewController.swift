//
//  ViewController.swift
//  OpenEarsSample1
//
//  Created by Tatsuya Moriguchi on 1/31/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController,OEEventsObserverDelegate {

    var openEarsEventsObserver = OEEventsObserver()

    // Initialize OEFliteController to use Slt Flite voice
    var fliteController = OEFliteController()
    var slt = Slt()



    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var hypothesisLabel: UILabel!
    
    @IBAction func startOnPressed(_ sender: UIButton) {

        if checkMicPermission() == true {
            lmGeneratorFunc()
            textLabel.text = "Button Pressed"
            
        } else {
            pocketsphinxFailedNoMicPermissions()
            textLabel.text = "Press Again"
        }


    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.openEarsEventsObserver.delegate = self


        // Perform text-to-speech
        let text2Speech = "Hello Dave. You're looking well today."
        self.fliteController.say(_:text2Speech, with:self.slt)
        hypothesisLabel.text = text2Speech


        if checkMicPermission() == true {
            textLabel.text = "Mic access was permitted"
          } else {
            pocketsphinxFailedNoMicPermissions()
            textLabel.text = "Mic access wasn't permitted."
          }

        
    }
 

    // To recognize speech
    func lmGeneratorFunc() {

         let lmGenerator = OELanguageModelGenerator()
        // Vocabulary (a language model) to recognize
         let words = ["Hello Hal", "Get", "Delete", "Update"] // These can be lowercase, uppercase, or mixed-case.
         let name = "NameIWantForMyLanguageModelFiles"
         let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))

         if(err != nil) {
            let message = "Error while creating initial language model: \(err)"
             messageOut(message: message)
         } else {
             let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name) // Convenience method to reference the path of a language model known to have been created successfully.
             let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name) // Convenience method to reference the path of a dictionary known to have been created successfully.
             

             // OELogging.startOpenEarsLogging() //Uncomment to receive full OpenEars logging in case of any unexpected results.
             do {
                 try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
                 } catch {
                    let message = "Error: it wasn't possible to set the shared instance to active: \"\(error)\""
                    print(message)
                    messageLabel.text = message + "\n" + messageLabel.text! + "\n"
                 }

                 OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)

         }

    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        
        let message = "Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)"
        messageOut(message: message)
        hypothesisLabel.text = "You probably said " + hypothesis
    }
       
    // An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
    // This might be useful in debugging a conflict between another sound class and Pocketsphinx.
    func pocketsphinxRecognitionLoopDidStart() {
        let message = "Local callback: Pocketsphinx started."
        messageLabel.text = ""
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
    func pocketsphinxDidStartListening() {
        let message = "Local callback: Pocketsphinx is now listening."
        messageOut(message: message)
        
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
    func pocketsphinxDidDetectSpeech() {
        let message = "Local callback: Pocketsphinx has detected speech."
        messageLabel.text = ""

        messageOut(message: message)
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
    func pocketsphinxDidDetectFinishedSpeech() {
        let message = "Local callback: Pocketsphinx has detected a second of silence, concluding an utterance."
        messageOut(message: message)
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
    // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
    func pocketsphinxDidStopListening() {
        let message = "Local callback: Pocketsphinx has stopped listening."
        messageOut(message: message)
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
    // Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
    // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
    func pocketsphinxDidSuspendRecognition() {
        let message = "Local callback: Pocketsphinx has suspended recognition."
        messageOut(message: message)
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
    // having been suspended it is now resuming.  This can happen as a result of Flite speech completing
    // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
    func pocketsphinxDidResumeRecognition() {
        let message = "Local callback: Pocketsphinx has resumed recognition."

        messageOut(message: message)
    }
    
    // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
    // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        let message = "Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)"

        messageOut(message: message)
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
    // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
    func fliteDidStartSpeaking() {
        let message = "Local callback: Flite has started speaking"
        messageOut(message: message)
        
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
    // complex interaction between sound classes.
    func fliteDidFinishSpeaking() {
        let message = "Local callback: Flite has finished speaking"
        messageOut(message: message)
        
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        let message = "Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more."
        messageOut(message: message)
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on OELogging.startOpenEarsLogging() to learn why.
        let message = "Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)"
        messageOut(message: message)
        
    }
    
    /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
    func pocketsphinxFailedNoMicPermissions() {
        let message = "Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start."
        messageOut(message: message)
    }
    
    /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result  (will only be returned on iOS7 or later).*/
    
    func micPermissionCheckCompleted(withResult: Bool) {
        let message = "Local callback: mic check completed."
        messageOut(message: message)
    }
    

    func messageOut(message: String) {
        print(message)
         messageLabel.text = message + "\n" + messageLabel.text! + "\n"
    }



    func checkMicPermission() -> Bool {

        var permissionCheck: Bool = false

        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            permissionCheck = true
        case AVAudioSessionRecordPermission.denied:
            permissionCheck = false
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }

        return permissionCheck
    }



}

