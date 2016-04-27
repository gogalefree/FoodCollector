//
//  NotificationBarButtonItem.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import Foundation

class NotificationBarButtonItem: UIBarButtonItem {

    var notificationsCountLabel: UILabel
    var button: UIButton
    
    func reloadCounterLabel() {
    
        let count = FCUserNotificationHandler.sharedInstance.notificationsBadgeCounter
        if count == 0 { notificationsCountLabel.animateToAlphaWithSpring(0.2, alpha: 0)}
        else if count > 0 {
            
            notificationsCountLabel.animateToAlphaWithSpring(0.2, alpha: 1)
            notificationsCountLabel.text = String(count)
        }
    }
    
    override func awakeFromNib() {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "Avtivity-center")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.frame = CGRectMake(0, 0, 27, 30)
        button.clipsToBounds = false
        button.tintColor = UIColor.whiteColor()
        
        let label = UILabel(frame: CGRectMake(20 , 0 , 20 , 20))
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.font = UIFont.boldSystemFontOfSize(9)
        label.text = ""
        label.textAlignment = .Center
        label.backgroundColor = UIColor.redColor()
        label.textColor = UIColor.whiteColor()
        label.alpha = 0
        
        button.addSubview(label)
        notificationsCountLabel = label
        self.customView = button
        self.tintColor = UIColor.whiteColor()
        self.button = button
    }
    
    required init?(coder aDecoder: NSCoder) {
        notificationsCountLabel = UILabel()
        button = UIButton()
        super.init(coder: aDecoder)
    }
}
