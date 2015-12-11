//
//  FCActivityCenterTVCSectionHeader.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/26/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

protocol ActivityCenterHeaderViewDelegate : NSObjectProtocol, UIGestureRecognizerDelegate{
    func headerTapped(section: Int)
}

let collectorIcon = UIImage(named: "CollectActivity")
let publisherIcon = UIImage(named: "DonateActivity")
let feedbackIcon  = UIImage(named: "Feedback")

class FCActivityCenterTVCSectionHeader: UIView {
    
    let textColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var blackBackgroundView: UIView!
    
    weak var delegate: ActivityCenterHeaderViewDelegate!

    var section: Int! {
        didSet {
            
            switch section {
            case 0:
                self.textLabel.text = collectorTitle
                self.iconImageView.image = collectorIcon
            case 1:
                self.textLabel.text = publisherTitle
                self.iconImageView.image = publisherIcon
            case 2:
                self.textLabel.text = feedbackTitle
                self.iconImageView.image = feedbackIcon
            default:
                break
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let delegate = self.delegate {
            delegate.headerTapped(section)
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel.textColor = self.textColor
    }
}
