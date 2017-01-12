//
//  gameVC.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/6/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit

import Alamofire
import Kanna
import Speech

var htmlGameString = ""
var indexPathOfChosenQuestion = 0

var arrayOfQuestions = [String]()
var PositionArrayOfBlankQuestions = [Int]()
var arrayOfQuestionCells = [questionButtonCell]()
var arrayOfAnswers = [String]()
var arrayOfAnswersToCompareWithVoice = [String]()
var arrayOfCategories = [String]()

var speechRecognitionEnabled = false

var gameCurrentlyGoing = false

var score = 0

class gameVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SFSpeechRecognizerDelegate {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .landscapeRight
        }
    }
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
//
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    appDelegate.shouldRotate = true // or false to disable rotation
    
    var count = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var collectionViewOfCategories: UICollectionView!
    
    @IBOutlet weak var collectionViewOfQuestionButtons: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewOfQuestionButtons.delegate = self
        collectionViewOfCategories.delegate = self
        
        collectionViewOfCategories.dataSource = self
        collectionViewOfQuestionButtons.dataSource = self
        
        speechRecognizer?.delegate = self
        
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
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(gameCurrentlyGoing){
            self.collectionViewOfQuestionButtons.reloadData()
            scoreLabel.isHidden = false
            scoreLabel.text = "Score: $\(score)"
        }
        else{
            scoreLabel.isHidden = true
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionViewOfCategories{
            return 6
        }
        
        else {
            return 30
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionViewOfCategories{
            
            let cell = collectionViewOfCategories.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryTitleCellCollectionViewCell
            
            cell.categoryLabel.adjustsFontSizeToFitWidth = true
            cell.categoryLabel.text = arrayOfCategories[indexPath.row]
            
            return cell
            
        }
        
        else
        {
            let cell = collectionViewOfQuestionButtons.dequeueReusableCell(withReuseIdentifier: "questionButtonCell", for: indexPath) as! questionButtonCell
            
            if(gameCurrentlyGoing){
                if(arrayOfQuestionCells[indexPath.row].questionAlreadyChosen){
                cell.questionMoney.text = ""
                return cell
                }
            }
            
            if(PositionArrayOfBlankQuestions.count > 0){
                for index in 0...PositionArrayOfBlankQuestions.count-1{
                    
                    if(indexPath.row == PositionArrayOfBlankQuestions[index]){
                        cell.questionMoney.text = ""
                        cell.questionAlreadyChosen = true
                        
                        if(!gameCurrentlyGoing){
                            arrayOfQuestionCells.append(cell)
                        }
                        
                        return cell
                    }
                }
            }
            
            if(indexPath.row < 6){
                cell.questionMoney.text = "$200"
            }
            else if(indexPath.row >= 6 && indexPath.row < 12){
                cell.questionMoney.text = "$400"
            }
            else if(indexPath.row >= 12 && indexPath.row < 18){
                cell.questionMoney.text = "$600"
            }
            else if(indexPath.row >= 18 && indexPath.row < 24){
                cell.questionMoney.text = "$800"
            }
            else if(indexPath.row >= 24){
                cell.questionMoney.text = "$1000"
            }
            
            if(!gameCurrentlyGoing){
                arrayOfQuestionCells.append(cell)
            }
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let cell = collectionViewOfQuestionButtons.cellForItem(at: indexPath) as! questionButtonCell
        
        //print(cell.questionAlreadyChosen)
        
        if(collectionView == collectionViewOfQuestionButtons){
            
            indexPathOfChosenQuestion = indexPath.row
            
            //checking if blank question
            if(PositionArrayOfBlankQuestions.count>0){
                for index in 0...PositionArrayOfBlankQuestions.count-1{
                    
                    if(indexPath.row == PositionArrayOfBlankQuestions[index]){
                        return
                    }
                }
            }
            
            if(!arrayOfQuestionCells[indexPath.row].questionAlreadyChosen){
                arrayOfQuestionCells[indexPath.row].questionAlreadyChosen = true
                performSegue(withIdentifier: "toQuestion", sender: Any?.self)
                //cell.questionAlreadyChosen = true
            }
    
        }
        //print(cell.questionAlreadyChosen)
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
