//
//  SwiftBadge.swift
//  FoodCollector
//
//  Created by Artyom on 4/15/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

//import UIKit

class FCActivityCenterTVCellBadgeLabel: UILabel {
    var defaultInsets = CGSize(width: 1, height: 1)
    var actualInsets = CGSize()
    
    override init() {
        super.init()
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        setTranslatesAutoresizingMaskIntoConstraints(false)
        
        layer.backgroundColor = UIColor.redColor().CGColor
        textColor = UIColor.whiteColor()
        
        // Shadow
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0.5
        layer.shadowColor = UIColor.blackColor().CGColor
        
        layer.cornerRadius = self.bounds.height / 2
        
        font = UIFont.systemFontOfSize(10)
    }
    

//    // Add custom insets
//    // --------------------
//    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        let rect = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines)
//        
//        actualInsets = defaultInsets
//        var rectWithDefaultInsets = CGRectInset(rect, -actualInsets.width, -actualInsets.height)
//        
//        // If width is less than height
//        // Adjust the width insets to make it look round
//        if rectWithDefaultInsets.width < rectWithDefaultInsets.height {
//            actualInsets.width = (rectWithDefaultInsets.height - rect.width) / 2
//        }
//        
//        return CGRectInset(rect, -actualInsets.width, -actualInsets.height)
//    }
//    
//    override func drawTextInRect(rect: CGRect) {
//        
//        layer.cornerRadius = rect.height / 2
//        
//        let insets = UIEdgeInsets(
//            top: actualInsets.height,
//            left: actualInsets.width,
//            bottom: actualInsets.height,
//            right: actualInsets.width)
//        
//        let rectWithoutInsets = UIEdgeInsetsInsetRect(rect, insets)
//        
//        super.drawTextInRect(rectWithoutInsets)
//    }
}

