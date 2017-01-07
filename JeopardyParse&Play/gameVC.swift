//
//  gameVC.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/6/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit
import Kanna
import Alamofire


class gameVC: UIViewController {
//
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    appDelegate.shouldRotate = true // or false to disable rotation
    
    var count = 0
    
    var temporaryArrayOfGameLinks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var whichSeason = arc4random_uniform(33) + 1
        
        self.scrapeJArchiveGameList(gameURL: "http://j-archive.com/showseason.php?season=\(whichSeason)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func scrapeJArchiveGameList(gameURL: String) {
        
        var gameLinkToParse = ""
        
        Alamofire.request(gameURL).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                gameLinkToParse = self.parseGameList(html: html)
            }
        }
        scrapeJArchiveGameTable(gameURL: gameLinkToParse)
    }
    
    func parseGameList(html: String) -> String{
        
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
        
        return(temporaryArrayOfGameLinks[pickRandomGameNumber])
        
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
