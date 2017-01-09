//
//  ResultViewController.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/8/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    var rightOrWrongLabelText: String = ""
    var correctAnswerLabelText: String = ""
    var scoreLabelText: String = ""
    var buzzerPressed: Bool = true
    
    @IBOutlet weak var rightOrWrongLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
