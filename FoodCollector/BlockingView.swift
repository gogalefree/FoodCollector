//
//  BlockingView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 22/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import Foundation

class BlockingView: UIView {

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        let dimmingView = UIView(frame: frame)
        dimmingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        self.addSubview(dimmingView)
        let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activity.frame.size = CGSizeMake(50, 50)
        activity.startAnimating()
        activity.center = self.center
        self.addSubview(activity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
