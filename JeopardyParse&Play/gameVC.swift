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
import FirebaseDatabase


var indexPathOfChosenQuestion = 0

var arrayOfQuestions = [String]()
var PositionArrayOfBlankQuestions = [Int]()
var arrayOfQuestionCells = [questionButtonCell]()
var arrayOfAnswers = [String]()
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

    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var collectionViewOfCategories: UICollectionView!
    
    @IBOutlet weak var collectionViewOfQuestionButtons: UICollectionView!
    
    let myRef: FIRDatabaseReference = FIRDatabase.database().reference().child(myKey)
    
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
            
            if(!isTurnToChooseQuestion(ref: myRef)){
                //checking if it is other's users turn, if it is, show an alert view
                createAlertButton()
            }
            
            else if(!arrayOfQuestionCells[indexPath.row].questionAlreadyChosen){
                arrayOfQuestionCells[indexPath.row].questionAlreadyChosen = true
                performSegue(withIdentifier: "toQuestion", sender: Any?.self)
            }
    
        }

    }
    
    
    //create alerts for when other person has to choose, when person has to choose
    
    func createAlertButton() {
        
        // create the alert
        let alert = UIAlertController(title: "Not your turn!", message: "Please wait, the other player is currently choosing", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        myRef.removeValue()
        
        // Remove Firebase Observers
        myRef.removeAllObservers()
    }

}

func isTurnToChooseQuestion(ref: FIRDatabaseReference) -> Bool
{
    
    var status = true
    //return true if person allowed to ask question
    ref.child("isChoosingQuestion").observeSingleEvent(of: .value, with: {(snapshot) in
    
        status = snapshot.value as! Bool

    })
    return status

}


