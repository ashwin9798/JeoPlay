//
//  UsernameViewController.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/11/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit
import FirebaseDatabase

var myUsername = ""
var myKey = ""

class UsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        usernameField.resignFirstResponder()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
    
        myKey = ref.child("Players").childByAutoId().key
        myUsername = usernameField.text!
        
        let player = Player(key: myKey, username: myUsername, opponentKey: "", gameURL: "", isChoosingQuestion: false, isWaitingForOtherToAnswer: false, score: 0)
        
        let childUpdates = ["\(myKey)" : player.getSnapshotValue()]
        
        ref.updateChildValues(childUpdates)
        
        performSegue(withIdentifier: "toLoadingScreen", sender: Any?.self)
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
