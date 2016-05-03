//
//  NotificationsDistanceVC.swift
//  SettingXMP
//
//  Created by Guy Freedman on 09/03/2016.
//  Copyright © 2016 TPApps. All rights reserved.
//

import UIKit

class NotificationsDistanceVC: UIViewController, DragViewDelegate {

    
    @IBOutlet weak var notificationsSwitch          : UISwitch!
    @IBOutlet weak var dragView                     : DragView!
    @IBOutlet weak var dragViewTrailingConstraint   : NSLayoutConstraint!
    @IBOutlet weak var circleView                   : UIView!
    @IBOutlet weak var circleViewWidth              : NSLayoutConstraint!
    @IBOutlet weak var circlViewHeight              : NSLayoutConstraint!
    @IBOutlet weak var dragBarLeftLeadingConstraint : NSLayoutConstraint!
    @IBOutlet weak var distanceLabel                : UILabel!
    //@IBOutlet weak var kmLabel                      : UILabel!
    @IBOutlet weak var circleViewBackground         : UIView!
    
    let dragViewMaxRightTrailingConst   : CGFloat = 42
    var circleViewIntialWidth           : CGFloat!
    var dragViewMaxLeftTrailungConst    : CGFloat!
    
    let blueColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
    let allText = NSLocalizedString("All", comment: "Notifications distance text. Means that all notifications will be delivered")
    let setDistanceTetxt = NSLocalizedString("Set The Distance", comment: "title of settings distance screen")
    
    @IBAction func switchDidMove(sender: AnyObject) {
        
        User.sharedInstance.settings.shouldPresentNotifications = notificationsSwitch.on
        
        if notificationsSwitch.on {
            animateWithAlpha(1)
        } else {
            animateWithAlpha(0)
        }
    }
    
    func animateWithAlpha(alpha: CGFloat) {
        UIView.animateWithDuration(0.2) { () -> Void in
            self.circleViewBackground.alpha = alpha
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func didDragWithDistance(distance: CGFloat) {

        
        //positive value is right drag
        
        if distance > 0 {
            let currentWidth = circleViewWidth.constant
            let newWidth = min(currentWidth + distance * 2, circleViewIntialWidth)
            
            circleViewWidth.constant = newWidth
            circlViewHeight.constant = newWidth
            
            let currentDragTrailing = dragViewTrailingConstraint.constant
            let newDragViewTrailing = max(currentDragTrailing - distance, dragViewMaxRightTrailingConst)
            
            dragViewTrailingConstraint.constant = newDragViewTrailing
            
            
            
        }
        
        //negative value is left drag
        if distance < 0 {
            
            let currentWidth = circleViewWidth.constant
            let newWidth =  max(currentWidth + distance * 2, 0)
            
            if newWidth <= 0 { return }

            circleViewWidth.constant = newWidth
            circlViewHeight.constant = newWidth
            

            let currentDragTrailing = dragViewTrailingConstraint.constant
            let newDragViewTrailing = currentDragTrailing - distance
            
            if newDragViewTrailing >= dragViewMaxLeftTrailungConst {return}

            
            dragViewTrailingConstraint.constant = newDragViewTrailing
            
        }
        
        self.calculateDistance()

        
        UIView.animateWithDuration(0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.circleView.layer.cornerRadius = self.circleViewWidth.constant / 2
        })
        
    }
    
    func dragDidStop() {
        self.circleView.layer.cornerRadius = self.circleViewWidth.constant / 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func calculateDistance() {
        
        let circleWidth = CGRectGetWidth(circleView.frame) - 30
        let fraction = circleWidth / (circleViewIntialWidth - 30)
        let distance = floor(fraction * CGFloat(60))
        let distanceInt = Int(distance)

        let multyplayer = floor(Double(distanceInt / 5))
        let value = Int(max(multyplayer * 5 , 1))
        //let alpha = value == 60 ? 0 :  1
        //kmLabel.alpha = CGFloat(alpha)
        value == 60 ? allText : String(value)
        let distanceText = String.localizedStringWithFormat(NSLocalizedString("%@ km", comment: "Notifications distance text. Means that notifications will be delivered based on the distance set by the user. the final string will look like this: '30 km'"), "\(value)")
        distanceLabel.text = distanceText
        User.sharedInstance.settings.notificationsRadius = value >= 59 ? 200 : value
    }
    
    func setup() {
    
        self.circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.layer.borderColor = blueColor.CGColor
        circleView.layer.borderWidth = 1
        circleView.clipsToBounds = true
        circleView.layer.masksToBounds = true
        circleView.backgroundColor = UIColor.whiteColor()
        dragView.layer.cornerRadius = dragView.frame.size.width / 2
        dragView.delegate = self
        
        print("circle height \(circleView.frame.size.height)")
        print("circle width \(circleView.frame.size.width)")
        distanceLabel.text = allText
        
        distanceLabel.textColor = blueColor
        //kmLabel.textColor = blueColor
        self.dragView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.8)
        //kmLabel.alpha = 0
        
        self.circleViewWidth.constant = self.view.frame.size.width - 2 * dragViewMaxRightTrailingConst
        self.circlViewHeight.constant = self.view.frame.size.width - 2 * dragViewMaxRightTrailingConst
        circleViewIntialWidth = self.view.frame.size.width - 2 * dragViewMaxRightTrailingConst
        dragViewMaxLeftTrailungConst = self.view.frame.size.width / 2
        dragBarLeftLeadingConstraint.constant = self.view.frame.size.width / 2
        dragDidStop()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 }
