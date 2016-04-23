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
            likeButton = FBSDKLikeControl(frame: CGRectMake(90 , 80 , 50 ,40))
            likeButton.transform = CGAffineTransformMakeScale(3, 0.8)
            likeButton.frame.origin = CGPointMake(110, 80)
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
