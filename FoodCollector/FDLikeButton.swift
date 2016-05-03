//
//  FDLikeButton.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/05/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class FDLikeButton: FBSDKLikeControl {

    func _auxiliaryView() -> UIView? {
        let imageView = UIImageView(image: UIImage(named:"Like_us"))
        imageView.frame = CGRectMake(0, 0, 150, 35)
        return imageView
    }

}
