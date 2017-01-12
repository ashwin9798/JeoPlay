//
//  Player.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/11/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import Foundation
import Firebase

class Player{
    
let key: String
let username: String
var isWaitingForOtherToAnswer: Bool

let kname = "username"
var kIsWaitingForOtherToAnswer = "isWaitingForSomeoneToAnswer"

init (key: String, username: String, isWaitingForOtherToAnswer: Bool)
{
    self.key = key
    self.username = username
    self.isWaitingForOtherToAnswer = isWaitingForOtherToAnswer
}

init(snapshot: FIRDataSnapshot)
{
    self.key = snapshot.key
    self.username = (snapshot.value as! NSDictionary)[self.kname] as! String
    self.isWaitingForOtherToAnswer = (snapshot.value as! NSDictionary)[self.kIsWaitingForOtherToAnswer] as! Bool
}

func getSnapshotValue() -> NSDictionary {
    return ["username": username, "isWaitingForOtherToAnswer": isWaitingForOtherToAnswer]
}

}
