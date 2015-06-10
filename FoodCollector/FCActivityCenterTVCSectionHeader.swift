//
//  FCActivityCenterTVCSectionHeader.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/26/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import UIKit

protocol ActivityCenterHeaderViewDelegate : NSObjectProtocol, UIGestureRecognizerDelegate{
    
    func headerTapped(section: Int)
}


class FCActivityCenterTVCSectionHeader: UIVisualEffectView {

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
            default:
                break
            }
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let delegate = self.delegate {
            delegate.headerTapped(section)
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.blackBackgroundView.layer.cornerRadius = 0
    }
}
