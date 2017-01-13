//
//  Player.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/11/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import Foundation
import Firebase

class Player: NSObject{
    
    let key: String
    let username: String
    var opponentKey: String
    var isChoosingQuestion: Bool
    var isWaitingForOtherToAnswer: Bool
    let gameURL: String
    var score: NSInteger

    let kname = "username"
    var kIsWaitingForOtherToAnswer = "isWaitingForOtherToAnswer"
    var kIsChoosingQuestion = "isChoosingQuestion"
    let kGameURL = "gameURL"
    let kOpponent = "opponentKey"
    let kScore = "score"
    
    init (key: String, username: String, opponentKey: String, gameURL: String, isChoosingQuestion: Bool, isWaitingForOtherToAnswer: Bool, score: NSInteger)
    {
        self.key = key
        self.username = username
        self.opponentKey = opponentKey
        self.gameURL = gameURL
        self.isChoosingQuestion = isChoosingQuestion
        self.isWaitingForOtherToAnswer = isWaitingForOtherToAnswer
        self.score = score
    }

    init(snapshot: FIRDataSnapshot)
    {
        self.key = snapshot.key
        self.username = (snapshot.value as! NSDictionary)[self.kname] as! String
        self.opponentKey = (snapshot.value as! NSDictionary)[self.kOpponent] as! String
        self.gameURL = (snapshot.value as! NSDictionary)[self.kGameURL] as! String
        self.isChoosingQuestion = (snapshot.value as! NSDictionary)[self.kIsChoosingQuestion] as! Bool
        self.isWaitingForOtherToAnswer = (snapshot.value as! NSDictionary)[self.kIsWaitingForOtherToAnswer] as! Bool
        self.score = (snapshot.value as! NSDictionary)[self.kScore] as! NSInteger
    }

    func getSnapshotValue() -> NSDictionary {
        return ["username": username, "opponentKey": opponentKey, "gameURL" : gameURL, "isChoosingQuestion": isChoosingQuestion, "isWaitingForOtherToAnswer": isWaitingForOtherToAnswer, "score": score]
    }
    
    func getUsername() -> String {
        
        return self.username
    }
    

    func hasBeenChosen() -> Bool {
        
        if (self.opponentKey != ""){
            return true
        }
        return false
        
    }

}

func getURL(ref: FIRDatabaseReference) -> String{
    
    var url = ""
    
    ref.observeSingleEvent(of: .value, with: {(snapshot) in
        
        url = snapshot.value as! String
        
    })
    return url
}
