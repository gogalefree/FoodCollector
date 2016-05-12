//
//  AboutUsLikeCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 23/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class AboutUsLikeCell: UITableViewCell {

    @IBOutlet weak var versionLabel: UILabel!
    var likeButton: FBSDKLikeControl!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if likeButton == nil {
            likeButton = FBSDKLikeControl()
            let likeButtonX = CGRectGetMinX(versionLabel.frame)
            let likeButtonY = CGRectGetMaxY(versionLabel.frame) + 10
            

            likeButton.frame.origin = CGPointMake(likeButtonX, likeButtonY)
         
            print("frame:\n\(likeButton.frame)")
            likeButton.objectID = "https://www.facebook.com/foodonet"
            likeButton.likeControlStyle = .Standard
            likeButton.likeControlHorizontalAlignment = .Center
            contentView.addSubview(likeButton)
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
