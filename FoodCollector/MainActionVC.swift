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

    @IBOutlet weak var mainLabelTopConstraint: NSLayoutConstraint!
    let topConstraintLandscapeConstant: CGFloat = 60
    let topConstraintPortraitConstant: CGFloat = 100

    
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var collectTitleButton: UIButton!
    @IBOutlet weak var publishTitleButton: UIButton!
    @IBOutlet weak var collectButton : UIButton!
    @IBOutlet weak var publishButton : UIButton!
    
    var statusBarView: UIView!

    weak var delegate: MainActionVCDelegate!
    
    final override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = mainActionVCTitle
        configureLabels()
        configureButtons()
        configureLabels()

        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(24) , NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func configureLabels() {
        
        collectTitleButton.setTitle(self.collectLabelText, forState: .Normal)
        publishTitleButton.setTitle(self.publishLabelText, forState: .Normal)
        mainTitleLabel.text = self.mainLabelText
        let buttons = [collectTitleButton, publishTitleButton]
        for button in buttons {
            button.setTitleColor(self.labelsTextColor, forState: .Normal)
        }
        self.mainTitleLabel.textColor = self.labelsTextColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.statusBarView == nil {
            
            self.statusBarView =  UIView(frame: CGRectMake(0, -20, CGRectGetWidth(self.view.bounds), 22))
            statusBarView.backgroundColor = UIColor.whiteColor()
            statusBarView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            self.navigationController?.navigationBar.addSubview(statusBarView)
        }
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
                
            case self.collectButton, self.collectTitleButton:
                delegate.mainActionVCDidRequestAction(.Collect)
            
            
            case self.publishButton, self.publishTitleButton:
                delegate.mainActionVCDidRequestAction(.Publish)
            
            default:
                break
            }
            
            //self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.navigationController?.view.alpha = 0
                }) {  (finished)->() in
            
                    self.navigationController?.view.removeFromSuperview()
                    self.navigationController?.removeFromParentViewController()
            }
            
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        if size.height > size.width {
            self.mainLabelTopConstraint.constant = self.topConstraintPortraitConstant
        }
        else {
            self.mainLabelTopConstraint.constant = self.topConstraintLandscapeConstant
            
        }
        self.view.layoutIfNeeded()
    }
}
