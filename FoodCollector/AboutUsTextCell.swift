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
    
    let aboutUsText = NSLocalizedString("Foodonet is a social initiative aiming to reduce food waste. Foodonet develops a mobile platform that allows people to easily donate spare food to one another. Foodonet is connecting food producers directly to customers with no mediators and cutting food costs", comment: "about us text")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainTextLabel.text = aboutUsText
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
