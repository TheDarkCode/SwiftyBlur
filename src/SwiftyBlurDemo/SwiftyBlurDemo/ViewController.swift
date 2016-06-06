//
//  ViewController.swift
//  SwiftyBlurDemo
//
//  Updates by Mark Hamilton on 6/5/16.
//  Copyright © 2016 dryverless. All rights reserved.
//
//  Based on MotionBlur by Guanshan Liu on 18/10/2014.
//  Copyright (c) 2014 guanshanliu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topMenu: UIImageView!
    @IBOutlet weak var topMenuHiddenConstraint: NSLayoutConstraint!
    @IBOutlet weak var toggleButton: UIButton!
    
    var strongTopMenuHiddenConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        strongTopMenuHiddenConstraint = topMenuHiddenConstraint
        strongTopMenuHiddenConstraint.priority = 1000
        
        toggleButton.setTitle("Creating...", forState: .Normal)
        toggleButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let time = calculateTime {
            
            self.topMenu.enableMotionBlur(Float(M_PI_2)) {
                self.delay(0) {
                    let strongSelf = self
                    strongSelf.toggleButton?.setTitle("Toggle", forState: .Normal)
                    strongSelf.toggleButton?.enabled = true
                }
            }
        }
        print(String(time))
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let time = calculateTime { self.topMenu.disableMotionBlur() }
        
        print(String(time))
    }
    
    @IBAction func move(sender: AnyObject) {
        let time = calculateTime {
            self.strongTopMenuHiddenConstraint.active = !self.strongTopMenuHiddenConstraint.active
            
            let hiding = self.strongTopMenuHiddenConstraint.active
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: hiding ? 0 : 0.6, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: { () -> Void in
                self.view.backgroundColor = hiding ? UIColor(white: 0.907, alpha: 1) : UIColor(white: 0.8, alpha: 1)
                self.topMenu.superview?.layoutIfNeeded()
                }, completion: nil)
        }
        
        print(String(time))
    }

}

