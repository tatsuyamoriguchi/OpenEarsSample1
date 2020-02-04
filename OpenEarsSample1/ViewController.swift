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
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var hypothesisLabel: UILabel!
    
    @IBAction func startOnPressed(_ sender: UIButton) {

        if checkMicPermission() == true {
            lmGeneratorFunc()
            textLabel.text = "Button Pressed"
            messageLabel.text = "This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. "
        } else {
            pocketsphinxFailedNoMicPermissions()
            textLabel.text = "Press Again"
        }


    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.openEarsEventsObserver.delegate = self

        if checkMicPermission() == true {
            textLabel.text = "Mic access was permitted"
          } else {
            pocketsphinxFailedNoMicPermissions()
            textLabel.text = "Mic access wasn't permitted."
          }

        
    }
 
    
    func lmGeneratorFunc() {

         let lmGenerator = OELanguageModelGenerator()
         let words = ["Hello Hal", "Get data", "Delete", "Update", "Open the pod bay doors"] // These can be lowercase, uppercase, or mixed-case.
         let name = "NameIWantForMyLanguageModelFiles"
         let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))

         if(err != nil) {
             print("Error while creating initial language model: \(err)")
            messageLabel.text = "Error while creating initial language model: \(err)" + "\n" + messageLabel.text! + "\n"
         } else {
             let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name) // Convenience method to reference the path of a language model known to have been created successfully.
             let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name) // Convenience method to reference the path of a dictionary known to have been created successfully.
             

             // OELogging.startOpenEarsLogging() //Uncomment to receive full OpenEars logging in case of any unexpected results.
             do {
                 try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
                 } catch {
                     print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
                    
                    messageLabel.text = "Error: it wasn't possible to set the shared instance to active: \"\(error)\"" + "\n" + messageLabel.text! + "\n"
                 }

                 OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)

         }

    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        messageLabel.text = "Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)" + "\n" + messageLabel.text! + "\n"
        hypothesisLabel.text = "You probably said " + hypothesis
    }
       
    // An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
    // This might be useful in debugging a conflict between another sound class and Pocketsphinx.
    func pocketsphinxRecognitionLoopDidStart() {
        print("Local callback: Pocketsphinx started.") // Log it.
        messageLabel.text = "Local callback: Pocketsphinx started." + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
    func pocketsphinxDidStartListening() {
        print("Local callback: Pocketsphinx is now listening.") // Log it.
        messageLabel.text = "Local callback: Pocketsphinx is now listening." + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
    func pocketsphinxDidDetectSpeech() {
        print("Local callback: Pocketsphinx has detected speech.") // Log it.
        
        messageLabel.text = "Local callback: Pocketsphinx has detected speech." + "\n" + messageLabel.text! + "\n"
        
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.") // Log it.
        messageLabel.text = "Local callback: Pocketsphinx has detected a second of silence, concluding an utterance." + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
    // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
    func pocketsphinxDidStopListening() {
        print("Local callback: Pocketsphinx has stopped listening.") // Log it.
        messageLabel.text = "Local callback: Pocketsphinx has stopped listening." + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
    // Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
    // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.") // Log it.
        messageLabel.text = "Local callback: Pocketsphinx has suspended recognition." + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
    // having been suspended it is now resuming.  This can happen as a result of Flite speech completing
    // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.") // Log it.
        messageLabel.text = "Local callback: Pocketsphinx has resumed recognition." + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
    // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
        
        messageLabel.text = "Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)" + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
    // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking") // Log it.
        messageLabel.text = "Local callback: Flite has started speaking" + "\n" + messageLabel.text! + "\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
    // complex interaction between sound classes.
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking") // Log it.
        messageLabel.text = "Local callback: Flite has finished speaking" + "\n" + messageLabel.text! + "\n"
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.") // Log it.
        messageLabel.text = "Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOp enEarsLogging() to learn more." + "\n" + messageLabel.text! + "\n"
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on OELogging.startOpenEarsLogging() to learn why.
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)") // Log it.
        messageLabel.text = "Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)" + "\n" + messageLabel.text! + "\n"
    }
    
    /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
    func pocketsphinxFailedNoMicPermissions() {
        print("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        messageLabel.text = "Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start." + "\n" + messageLabel.text! + "\n"
    }
    
    /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result  (will only be returned on iOS7 or later).*/
    
    func micPermissionCheckCompleted(withResult: Bool) {
        print("Local callback: mic check completed.")
        messageLabel.text = "Local callback: mic check completed." + "\n" + messageLabel.text! + "\n"
        
        
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

