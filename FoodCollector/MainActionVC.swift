//
//  MainActionVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 7/5/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

enum MainActionType: Int {
    case Collect = 0
    case Publish = 1
}

protocol MainActionVCDelegate: NSObjectProtocol {
    func mainActionVCDidRequestAction(actionType: MainActionType)
}


class MainActionVC: UIViewController {
    
    let mainActionVCTitle = String.localizedStringWithFormat("ברוכים הבאים", "main action vc title")
    let mainLabelText = String.localizedStringWithFormat("מה תרצו לעשות?", "main action vc title")
    let collectLabelText = String.localizedStringWithFormat("לאסוף מזון", "main action vc title")
    let publishLabelText = String.localizedStringWithFormat("לשתף מזון", "main action vc title")
    let labelsTextColor = UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1)

    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var collectTitleLabel: UILabel!
    @IBOutlet weak var publishTitleLabel: UILabel!
    @IBOutlet weak var collectButton : UIButton!
    @IBOutlet weak var publishButton : UIButton!

    weak var delegate: MainActionVCDelegate!
    
    final override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = mainActionVCTitle
        configureLabels()
        configureButtons()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(24) , NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func configureLabels() {
        
        collectTitleLabel.text = self.collectLabelText
        publishTitleLabel.text = self.publishLabelText
        mainTitleLabel.text = self.mainLabelText
        let labels = [collectTitleLabel, publishTitleLabel, mainTitleLabel]
        for label in labels {
            label.textColor = self.labelsTextColor
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setNeedsStatusBarAppearanceUpdate()
        
        let statusBarView = UIView(frame: CGRectMake(0, -20, 320, 22))
        statusBarView.backgroundColor = UIColor.whiteColor()
        statusBarView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.navigationController?.navigationBar.addSubview(statusBarView)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func configureButtons() {
        let buttons = [collectButton, publishButton]
        for button in buttons {
            button.layer.cornerRadius = CGRectGetWidth(button.bounds) / 2
            button.backgroundColor = kNavBarBlueColor
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.delegate = nil
    }
  
    @IBAction func actionPressed(sender: UIButton!) {
        
        if let delegate = self.delegate {
            
            switch sender {
                
            case self.collectButton:
                delegate.mainActionVCDidRequestAction(.Collect)
            
            
            case self.publishButton:
                delegate.mainActionVCDidRequestAction(.Publish)
            
            default:
                break
            }
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
