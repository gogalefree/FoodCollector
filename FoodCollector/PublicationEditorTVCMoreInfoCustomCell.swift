//
//  PublicationEditorTVCMoreInfoCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 08/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCMoreInfoCustomCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    
    let digits = "0123456789"
    var onlyDigitsPhoneString = ""
    var isPhoneNumberValid = false
    
    var cellData: PublicationEditorTVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                self.cellLabel.text = cellData.cellTitle
            }
        }
    }

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellLabel.text = ""
    }
    
}
