//
//  UserProfileTextCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 21/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class UserProfileTextCell: UITableViewCell {
    
    enum CellType {case NameCell , PhoneNumberCell}
    
    var type: CellType = .NameCell

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
