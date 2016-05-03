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
    var likeButton: FDLikeButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if likeButton == nil {
            likeButton = FDLikeButton()
            likeButton.frame = CGRectMake(90, 50, 150, 35)  
         //   likeButton.transform = CGAffineTransformMakeScale(3, 0.8)
         //   likeButton.frame.origin = CGPointMake(110, 80)
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
