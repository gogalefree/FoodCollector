//
//  FCPublishAddressEditorAddressHistoryCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 29/07/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class FCPublishAddressEditorAddressHistoryCustomCell: UITableViewCell {
    
    @IBOutlet weak var addressName: UILabel!
    
    //var addressListItem = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.addressName.text = self.addressListItem
        //println("self.addressName.text: \(self.addressName.text)")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
