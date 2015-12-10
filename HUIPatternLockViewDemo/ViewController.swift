//
//  ViewController.swift
//  HUIPatternLockViewDemo
//
//  Created by ZhangTinghui on 15/10/25.
//  Copyright © 2015年 www.morefun.mobi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var lockView: HUIPatternLockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* un-comment these lines to use dot image instead of self drawing code
        lockView.normalDotImage = UIImage(named: "dot_normal")
        lockView.highlightedDotImage = UIImage(named: "dot_highlighted")
        */
        lockView.password = "[1][2][3]"
        lockView.didDrawPatternWithPassword = { (view: HUIPatternLockView, count: Int, password: String?) -> Void in
            self.label.text = "Get Password: " + password!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

