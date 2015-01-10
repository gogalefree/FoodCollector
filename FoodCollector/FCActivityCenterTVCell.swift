//
//  FCActivityCenterTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCActivityCenterTVCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.textColor = UIColor.whiteColor()
        
         self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:55 ))
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.iconImageView.image = nil
        self.userInteractionEnabled = false

    }

}
