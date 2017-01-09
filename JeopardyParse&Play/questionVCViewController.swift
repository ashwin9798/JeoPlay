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
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var timeLeftToAnswerLabel: UILabel!
    @IBOutlet weak var buzzerButton: UIButton!
    @IBOutlet weak var recordingGraphic: UIActivityIndicatorView!
    
    var timer: Timer!
    
    var timeLeftToAnswer: Timer!
    var timeLeft: Int = 7
    var buzzerPressedAlready: Bool = false
    
    var timeLeftToBuzz: Timer!
    var timeLeft1: Int = 7
    
    var startRecordingTimer: Timer!
    
    var speechRecognizedAlready: Bool = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // either correct, incorrect, or no answer
    var wasCorrectAnswer: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameCurrentlyGoing = true
        
        recordingLabel.isHidden = true
        recordingGraphic.isHidden = true
        timeLeftToAnswerLabel.isHidden = true
        timeLeft = 7
        timeLeft1 = 7
        
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

        timeLeftToBuzz = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown1), userInfo: nil, repeats: true)
        
        self.questionText.text = arrayOfQuestions[indexPathOfChosenQuestion]
        
        self.questionText.adjustsFontSizeToFitWidth = true

        // Do any additional setup after loading the view.
    }
    @IBAction func buzzerPressed(_ sender: Any) {
        
        startTimer()
        timeLeftToBuzz.invalidate()
    }
    
    func startTimer(){
        recordingGraphic.startAnimating()
        recordingGraphic.isHidden = false
        recordingLabel.isHidden = false
        timeLeftToAnswerLabel.isHidden = false
        
        timeLeftToAnswer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
        
        startRecording()
    }
    
    func runTimedCode(){
        
        recordingLabel.isHidden = true
        recordingGraphic.isHidden = true
        timeLeftToAnswerLabel.isHidden = true
        audioEngine.stop()
        recognitionRequest?.endAudio()
        timer.invalidate()
        
    }
    
    func countdown1(){
        recordingGraphic.startAnimating()
        timeLeftToAnswerLabel.isHidden = false
        recordingGraphic.isHidden = false
        
        if(timeLeft1 == 0){
            self.wasCorrectAnswer = 3
            performSegue(withIdentifier: "toResult", sender: Any?.self)
            timeLeftToBuzz.invalidate()
        }
        timeLeft1 -= 1
        timeLeftToAnswerLabel.text = "you have \(timeLeft1) seconds to buzz"
    }
    
    func countdown(){
        
        if(timeLeft == 0){
            timeLeftToAnswer.invalidate()
        }
        timeLeft -= 1
        timeLeftToAnswerLabel.text = "\(timeLeft)"
        
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
        
        //change this
        recognitionRequest.shouldReportPartialResults = false
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil && !self.speechRecognizedAlready{
                
                //different sentence structures
                if((result?.bestTranscription.formattedString)!.lowercased() == "what is \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())"
                    || (result?.bestTranscription.formattedString)!.lowercased() == "what are \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())"
                    || (result?.bestTranscription.formattedString)!.lowercased() == "who is \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())"
                    || (result?.bestTranscription.formattedString)!.lowercased() == "who are \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())"
                    || (result?.bestTranscription.formattedString)!.lowercased() == "where is \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())"){
                    
                    print("Your answer: \((result?.bestTranscription.formattedString)!.lowercased())")
                    print("Correct answer: \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())")
                    
                    score += self.questionValue()
                    self.wasCorrectAnswer = 0
                    self.speechRecognizedAlready = true
                    
                    self.performSegue(withIdentifier: "toResult", sender: Any?.self)
                    
                }
                else{
                    
                    print("Your answer: \((result?.bestTranscription.formattedString)!.lowercased())")
                    print("Correct answer: \(arrayOfAnswers[indexPathOfChosenQuestion].lowercased())")
                    
                    score -= self.questionValue()
                    self.wasCorrectAnswer = 1
                    self.speechRecognizedAlready = true
                    
                    self.performSegue(withIdentifier: "toResult", sender: Any?.self)
                }
                isFinal = (result?.isFinal)!
                return
            }
            
            if ((error != nil || isFinal) && !self.speechRecognizedAlready) {
                
                if(error != nil){
                    self.wasCorrectAnswer = 2
                    self.performSegue(withIdentifier: "toResult", sender: Any?.self)
                    
                }
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.timer.invalidate()
                return
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
        else{
            return 1000
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toResult"{
            
            //create data push through segue!
            let answerData = segue.destination as! ResultViewController
            
            switch(self.wasCorrectAnswer){
                
            case 0:
                answerData.rightOrWrongLabelText = "That's right!";
                answerData.correctAnswerLabelText = "";
                answerData.scoreLabelText = "Score: $\(score)";
                break;
                
            case 1:
                answerData.rightOrWrongLabelText = "Sorry, that's incorrect";
                answerData.correctAnswerLabelText = "the correct answer was:                              what is \(arrayOfAnswers[indexPathOfChosenQuestion])?";
                answerData.scoreLabelText = "Score: $\(score)";
                break;
                
            case 2:
                answerData.rightOrWrongLabelText = "Oops, we cannot recognize this answer, even if you were right! (No point deduction)";
                answerData.correctAnswerLabelText = "the correct answer was:                              what is \(arrayOfAnswers[indexPathOfChosenQuestion])?";
                answerData.scoreLabelText =  "Score: $\(score)";
                break;
                
            case 3:
                answerData.rightOrWrongLabelText = "You didn't buzz!";
                answerData.correctAnswerLabelText = "the correct answer was:                              what is \(arrayOfAnswers[indexPathOfChosenQuestion])";
                answerData.scoreLabelText =  "Score: $\(score)";
                
            default:
                break;
            
            }
        
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
