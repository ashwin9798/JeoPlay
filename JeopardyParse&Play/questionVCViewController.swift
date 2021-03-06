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
    var timeLeft: Int = 5
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
    var answerHeard: String = ""
    
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
            timeLeftToAnswerLabel.isHidden = true
            timeLeftToBuzz.invalidate()
            self.wasCorrectAnswer = 3
            performSegue(withIdentifier: "toResult", sender: Any?.self)
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
                
                if(self.questionFormatForAnswerScreen(recognizedAnswer: (result?.bestTranscription.formattedString)!.lowercased()) == "not a response"){
                    self.wasCorrectAnswer = 4
                    score -= self.questionValue()
                    self.speechRecognizedAlready = true
                    self.performSegue(withIdentifier: "toResult", sender: Any?.self)
                }
                
                if(
                    self.isAnswerCloseEnough(recognizedAnswer: (result?.bestTranscription.formattedString)!.lowercased(), actualAnswer: "what is \(arrayOfAnswersToCompareWithVoice[indexPathOfChosenQuestion].lowercased())")
                    || self.isAnswerCloseEnough(recognizedAnswer: (result?.bestTranscription.formattedString)!.lowercased(), actualAnswer: "what are \(arrayOfAnswersToCompareWithVoice[indexPathOfChosenQuestion].lowercased())")
                    || self.isAnswerCloseEnough(recognizedAnswer: (result?.bestTranscription.formattedString)!.lowercased(), actualAnswer: "who is \(arrayOfAnswersToCompareWithVoice[indexPathOfChosenQuestion].lowercased())")
                    || self.isAnswerCloseEnough(recognizedAnswer: (result?.bestTranscription.formattedString)!.lowercased(), actualAnswer: "who are \(arrayOfAnswersToCompareWithVoice[indexPathOfChosenQuestion].lowercased())")
                    || self.isAnswerCloseEnough(recognizedAnswer: (result?.bestTranscription.formattedString)!.lowercased(), actualAnswer: "where is \(arrayOfAnswersToCompareWithVoice[indexPathOfChosenQuestion].lowercased())")){
                    
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
                    self.answerHeard = (result?.bestTranscription.formattedString)!.lowercased()
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
                answerData.correctAnswerLabelText = "the correct response was:                              \(questionFormatForAnswerScreen(recognizedAnswer: answerHeard)) \(arrayOfAnswers[indexPathOfChosenQuestion])?";
                answerData.scoreLabelText = "Score: $\(score)";
                break;
                
            case 2:
                answerData.rightOrWrongLabelText = "Oops, we didn't detect a valid answer!";
                answerData.correctAnswerLabelText = "the correct response was:                              what is \(arrayOfAnswers[indexPathOfChosenQuestion])?";
                answerData.scoreLabelText =  "Score: $\(score)";
                break;
                
            case 3:
                answerData.rightOrWrongLabelText = "You didn't buzz!";
                answerData.correctAnswerLabelText = "the correct response was:                              what is \(arrayOfAnswers[indexPathOfChosenQuestion])?";
                answerData.scoreLabelText =  "Score: $\(score)";
                break;
            
            case 4:
                answerData.rightOrWrongLabelText = "Oops, you didn't phrase your response as a question!";
                answerData.correctAnswerLabelText = "the correct response was:                               what is \(arrayOfAnswers[indexPathOfChosenQuestion])?";
                answerData.scoreLabelText =  "Score: $\(score)";
                break;

            default:
                break;
            
            }
        
        }
    }
    
    func isAnswerCloseEnough(recognizedAnswer: String, actualAnswer: String) -> Bool{
        
        var lastSpace = -1
        var lastSpace1 = -1
        var arrayOfWordsInActualAnswer = [String]()
        var arrayOfWordsInRecognizedAnswer = [String]()
        
        var numberOfMatchingWords = 0
        
        for index in 0...actualAnswer.characters.count-1{
            
            if(actualAnswer[index] == " "){
                
                arrayOfWordsInActualAnswer.append(actualAnswer[lastSpace+1..<index])
                lastSpace = index
            }
            if(index == actualAnswer.characters.count-1){
                
                arrayOfWordsInActualAnswer.append(actualAnswer[lastSpace+1..<index+1])
            }
        }
        
        for index in 0...recognizedAnswer.characters.count-1{
            
            if(recognizedAnswer[index] == " "){
                
                arrayOfWordsInRecognizedAnswer.append(recognizedAnswer[lastSpace1+1..<index])
                lastSpace1 = index
            }
            if(index == recognizedAnswer.characters.count-1){
                
                arrayOfWordsInRecognizedAnswer.append(recognizedAnswer[lastSpace1+1..<index+1])
            }
        }
        
        for index in 0...arrayOfWordsInActualAnswer.count-1{
            
            for index1 in 0...arrayOfWordsInRecognizedAnswer.count-1{
             
                if(arrayOfWordsInRecognizedAnswer[index1].lowercased() == arrayOfWordsInActualAnswer[index].lowercased()){
                    
                    numberOfMatchingWords += 1
                    
                }
                
            }
        }
        
        if(arrayOfWordsInActualAnswer.count - numberOfMatchingWords < arrayOfWordsInActualAnswer.count - 2){
            return true
        }
        else{
            return false
        }
        
    }
    
    
    func questionFormatForAnswerScreen(recognizedAnswer: String)->String{
        //returns the question format of answer when user is wrong
        var whiteSpaceCount = 0
        var indexOfSpace = 0
        var questionString = ""
        
        for index in 0...recognizedAnswer.characters.count-1{
            if(recognizedAnswer[index] == " "){
                whiteSpaceCount += 1;
                if(whiteSpaceCount == 2){
                    indexOfSpace = index
                    break
                }
            }
        }
        questionString = recognizedAnswer[0..<indexOfSpace]
        
        if(questionString == "what is" || questionString == "what are" || questionString == "who is" || questionString == "where is" || questionString == "who are"){
            return questionString
        }
        else{
            return "not a response"
        }
    }

}
