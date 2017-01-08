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

var speechRecognitionEnabled = false

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
    
    //variable holding game links before random selection
    var temporaryArrayOfGameLinks = [String]()
    
    //variable to hold all category names
    var arrayOfCategories = [String]()
    
    @IBOutlet weak var collectionViewOfCategories: UICollectionView!
    
    @IBOutlet weak var collectionViewOfQuestionButtons: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let whichSeason = arc4random_uniform(33) + 1
        
        self.scrapeJArchiveGameList(gameURL: "http://j-archive.com/showseason.php?season=\(whichSeason)")
        // Do any additional setup after loading the view.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func scrapeJArchiveGameList(gameURL: String) {
        
        Alamofire.request(gameURL).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseGameList(html: html)
            }
        }
    }
    
    func parseGameList(html: String){
        
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            
            let bodyNode = doc.body
            
            if let inputNodes = bodyNode?.xpath("//a/@href"){
                
                for node in inputNodes{
                    
                    count += 1
                    
                    if(count > 7){
                        if(node.content?.range(of: "http://www.j-archive.com/showgame.php?game_id=") != nil){
                            
                            temporaryArrayOfGameLinks.append(node.content!)
                            
                        }
                    }
                }
            }
            
        }
        
        let pickRandomGameNumber = Int(arc4random_uniform(UInt32(temporaryArrayOfGameLinks.count)))
        
        htmlGameString = temporaryArrayOfGameLinks[pickRandomGameNumber]
        scrapeJArchiveGameTable(gameURL:(temporaryArrayOfGameLinks[pickRandomGameNumber]))
        
    }
    
    func scrapeJArchiveGameTable(gameURL: String){
        
        Alamofire.request(gameURL).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseGameTable(html: html)
            }
        }
    }
    
    func parseGameTable(html: String){
    
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8){
            
            let bodyNode = doc.body
            
            if let categories = bodyNode?.xpath("//td[@class='category_name']"){
                
                for node in categories{
                    arrayOfCategories.append(node.content!)
                    print(node.content!)
                }
                
            }
            
            if let numberOfQuestions = bodyNode?.xpath("//td[@class='clue']"){
            
                var count = 0
                
                for node in numberOfQuestions{
    
                    if(node.text! == ""){
                        PositionArrayOfBlankQuestions.append(count)
                    }
                    count += 1
                }
            
            }
            
            if let questions = bodyNode?.xpath("//td[@class='clue_text']"){
                
                for node in questions{
                    arrayOfQuestions.append(node.text!)
                    print(node.text!)
                }
                
            }
            
            if let answers = bodyNode?.xpath("//div/@onmouseover"){
                for node in answers{
                    arrayOfAnswers.append(extractAnswerFromNode(elements: node.text!))
                    print(extractAnswerFromNode(elements: node.text!))
                }
            }
            
        }
        
        collectionViewOfCategories.delegate = self
        collectionViewOfCategories.dataSource = self
        
        collectionViewOfQuestionButtons.delegate = self
        collectionViewOfQuestionButtons.dataSource = self
        
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
        
        else {
            
            let cell = collectionViewOfQuestionButtons.dequeueReusableCell(withReuseIdentifier: "questionButtonCell", for: indexPath) as! questionButtonCell
            
            if(PositionArrayOfBlankQuestions.count > 0){
                for index in 0...PositionArrayOfBlankQuestions.count-1{
                    
                    if(indexPath.row == PositionArrayOfBlankQuestions[index]){
                        cell.questionMoney.text = ""
                        cell.questionAlreadyChosen = true
                        
                        arrayOfQuestionCells.append(cell)
                        
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
            
            arrayOfQuestionCells.append(cell)
            
            return cell
            
        }
        
    }
    
    func extractAnswerFromNode(elements: String) -> String{
        
        var substring = ""
        
        for index in 71...elements.characters.count-1{
            
            if(elements[index] == "<"){
                
                substring = elements[70..<index]
                break
                
            }
        }
        return substring
        
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
