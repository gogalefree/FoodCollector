//
//  sideMenuItemTVCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 5.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class sideMenuItemTVCell: UITableViewCell {
    
    
    @IBOutlet weak var sideMenuIcon: UIImageView!
    @IBOutlet weak var sideMenuTitle: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //sideMenuIcon.image = UIImage()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
