//
//  questionVCViewController.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/7/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import Speech

class questionVCViewController: UIViewController {

    @IBOutlet weak var questionText: UILabel!
    
    var timer: Timer!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {  //5
            case .authorized:
                speechRecognitionEnabled = true
                
            case .denied:
                speechRecognitionEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                speechRecognitionEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                speechRecognitionEnabled = false
                print("Speech recognition not yet authorized")
            }
        }

        self.questionText.text = arrayOfQuestions[indexPathOfChosenQuestion]
        
        self.questionText.adjustsFontSizeToFitWidth = true
        
        startRecording()

        // Do any additional setup after loading the view.
    }
    
    func runTimedCode(){
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
    }

    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                if(result?.bestTranscription.formattedString == arrayOfAnswers[indexPathOfChosenQuestion]){
                    
                    score += self.questionValue()
                    
                }
                else{
                    score -= self.questionValue()
                }
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.timer.invalidate()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
//        textView.text = "Say something, I'm listening!"
        
    }
    
    
    func questionValue() -> Int{
        
        if(indexPathOfChosenQuestion < 6){
            return 200
        }
        else if(indexPathOfChosenQuestion >= 6 && indexPathOfChosenQuestion < 12){
            return 400
        }
        else if(indexPathOfChosenQuestion >= 12 && indexPathOfChosenQuestion < 18){
            return 600
        }
        else if(indexPathOfChosenQuestion >= 18 && indexPathOfChosenQuestion < 24){
            return 800
        }
        else if(indexPathOfChosenQuestion >= 24){
            return 1000
        }
    }




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
