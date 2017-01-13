//
//  ScrapeGameVC.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/9/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import FirebaseDatabase

var htmlGameString = ""     //variable holding the common url between the two players
var opponentKey = ""

class ScrapeGameVC: UIViewController {
    
    var count = 0
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingGraphic: UIActivityIndicatorView!
    //variable holding game links before random selection
    var temporaryArrayOfGameLinks = [String]()
    
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .landscapeRight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        loadingGraphic.startAnimating()
        loadingLabel.text = "Looking for opponents"
        
        let whichSeason = arc4random_uniform(33) + 1
        
        //Find opponents
        
        self.scrapeJArchiveGameList(gameURL: "http://j-archive.com/showseason.php?season=\(whichSeason)")
        
        ref.observe(.childAdded, with: {(snapshot) in
        
            let observedKey = snapshot.key
            let player = Player(snapshot: snapshot)
            
            if(!player.hasBeenChosen() && observedKey != myKey){

                opponentKey = observedKey   //store for use later
                
                let competitorRef: FIRDatabaseReference = FIRDatabase.database().reference().child("\(observedKey)").child("opponentKey")
                
                competitorRef.setValue(myKey)
                self.ref.child(observedKey).child("gameURL").setValue(htmlGameString)
    
                
                self.ref.child("opponentKey").setValue(observedKey)
                self.ref.child("gameURL").setValue(htmlGameString)
                self.ref.child("isChoosingFirst").setValue(true)
          
                self.loadingLabel.text! = "Playing against \(player.getUsername)"
            }
            
        })
        scrapeJArchiveGameTable(gameURL: getURL(ref: ref.child("gameURL")))
        
        performSegue(withIdentifier: "toGame", sender: Any?.self)
        
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
                    if(!gameCurrentlyGoing){
                        arrayOfCategories.append(node.content!)
                    }
                    print(node.content!)
                }
                
            }
            
            if let numberOfQuestions = bodyNode?.xpath("//td[@class='clue']"){
                
                var count = 0
                
                for node in numberOfQuestions{
                    
                    if(node.text! == ""){
                        if(!gameCurrentlyGoing){
                            PositionArrayOfBlankQuestions.append(count)
                        }
                    }
                    count += 1
                }
                
            }
            
            if let questions = bodyNode?.xpath("//td[@class='clue_text']"){
                
                for node in questions{
                    if(!gameCurrentlyGoing){
                        arrayOfQuestions.append(node.text!)
                    }
                    print(node.text!)
                }
                
            }
            
            if let answers = bodyNode?.xpath("//div/@onmouseover"){
                for node in answers{
                    if(!gameCurrentlyGoing){
                        arrayOfAnswers.append(extractAnswerFromNode(elements: node.text!))
                    }
                    print (node.text!)
                    print(extractAnswerFromNode(elements: node.text!))
                }
            }
            
        }
        //segue was here
    }
    
    func extractAnswerFromNode(elements: String) -> String{
        
        var substring = ""
        var startPos = 0
        
        for index1 in 0...elements.characters.count-1{
            
            if(elements[index1] == ">")
            {
                if(elements[index1-1] == "\"" || elements[index1-1] == "i")
                {
                    if(elements[index1-1] == "\""){
                        if(elements[index1-18..<(index1)] == "\"correct_response\"" && elements[index1+1] != "<"){
                            print("\"correct_response\"")
                            startPos = index1
                            break
                        }
                    }
                    else if(elements[index1-1] == "i"){
                        startPos = index1
                        break
                    }
                }
            }
        }
        
        for index in startPos+1...elements.characters.count-1{
            
            if(elements[index] == "<"){
                
                substring = elements[startPos+1..<index]
                break
                
            }
        }
        
        substring = substring.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        return substring
    }
    
    
    
}
