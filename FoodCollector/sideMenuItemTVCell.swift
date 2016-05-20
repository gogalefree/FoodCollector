//
//  sideMenuItemTVCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 5.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class sideMenuItemTVCell: UITableViewCell {
    
    
    @IBOutlet weak var sideMenuIcon: UIImageView!
    @IBOutlet weak var sideMenuTitle: UILabel!
    @IBOutlet weak var notificationsCounterLabel: UILabel!
    
    var indexPath: NSIndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        notificationsCounterLabel.alpha = 0
        notificationsCounterLabel.layer.cornerRadius = 10
        notificationsCounterLabel.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let indexPath = indexPath else {return}
        if indexPath.row == 3 {
            updateNotificationLabel()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.notificationsCounterLabel.alpha = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateNotificationLabel() {
        
        let counter = FCUserNotificationHandler.sharedInstance.notificationsBadgeCounter
        notificationsCounterLabel.alpha = 0
        if counter == 0 {return}
       
        notificationsCounterLabel.text = String(counter)
        UIView.animateWithDuration(0.2) { 
            self.notificationsCounterLabel.alpha = 1
        }
        
    }

}
