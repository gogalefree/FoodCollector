//
//  AboutUsTextCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 23/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class AboutUsTextCell: UITableViewCell {

    @IBOutlet weak var mainTextLabel: UILabel!
    
    let aboutUsText = NSLocalizedString("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. ", comment: "about us text")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainTextLabel.text = aboutUsText
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
