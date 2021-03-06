//
//  UIImage+Extensions.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/14/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    class func imageWithColor(color: UIColor, view:UIView) -> UIImage {
     
        let rect = CGRectMake(0, 0, view.bounds.width, 44)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}