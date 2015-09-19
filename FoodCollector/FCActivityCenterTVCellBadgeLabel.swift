//
//  SwiftBadge.swift
//  FoodCollector
//
//  Created by Artyom on 4/15/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation
import UIKit

class FCActivityCenterTVCellBadgeLabel: UILabel {
    
    var defaultInsets = CGSize(width: 1, height: 1)
    var actualInsets = CGSize()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.backgroundColor = UIColor.redColor().CGColor
        textColor = UIColor.whiteColor()
        layer.cornerRadius = self.bounds.height / 2
        font = UIFont.systemFontOfSize(10)
        self.alpha = 0

        
//        // Shadow
//        layer.shadowOpacity = 0.5 as Float
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowRadius = 0.5
//        layer.shadowColor = UIColor.blackColor().CGColor
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
}

