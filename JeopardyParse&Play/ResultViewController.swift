//
//  ResultViewController.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/8/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ResultViewController: UIViewController {

    var rightOrWrongLabelText: String = ""
    var correctAnswerLabelText: String = ""
    var scoreLabelText: String = ""
    var buzzerPressed: Bool = true
    
    @IBOutlet weak var rightOrWrongLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var firstAnswerWasWrong: Bool = false
    var secondAnswerWasWrong: Bool = false
    
    var timeLeftToViewAnswer: Timer!
    var timeLeft: Int = 6

    var opponentRef: FIRDatabaseReference = FIRDatabase.database().reference().child(opponentKey)   //reference for opponent data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLeftToViewAnswer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(segueAfterTimer), userInfo: nil, repeats: true)

        rightOrWrongLabel.text = "\(rightOrWrongLabelText)"
        rightOrWrongLabel.adjustsFontSizeToFitWidth = true
        correctAnswerLabel.text = "\(correctAnswerLabelText)"
        scoreLabel.text = "\(scoreLabelText)"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segueAfterTimer(){
        
        opponentRef.child("isWaitingForOtherToAnswer").setValue(false)
        performSegue(withIdentifier: "backToTableScreen", sender: Any?.self)
        
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
