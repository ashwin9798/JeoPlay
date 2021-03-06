//
//  ViewController.swift
//  JeopardyParse&Play
//
//  Created by Ashwin Vivek on 1/6/17.
//  Copyright © 2017 AshwinVivek. All rights reserved.
//

import UIKit
import Alamofire
import Kanna


class ViewController: UIViewController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .landscapeRight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

