//
//  PublicationDetailsDetailsTVCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 4.4.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class PublicationDetailsDetailsTVCell: UITableViewCell {
    
    @IBOutlet weak var shareUserImage: UIImageView!
    
    @IBOutlet weak var shareLocationLabel: UILabel!
    
    @IBOutlet weak var shareUserNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shareUserImage.layer.cornerRadius = CGRectGetWidth(shareUserImage.frame)/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
