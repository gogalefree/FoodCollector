//
//  PublicationOptionsMenuItemCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 05/09/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationOptionsMenuItemCell: UITableViewCell {
    
    @IBOutlet weak var menuItemTitle: UILabel!
    
    
    @IBOutlet weak var menuItemIcon: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
