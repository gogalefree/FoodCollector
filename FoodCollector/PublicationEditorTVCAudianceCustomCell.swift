//
//  PublicationEditorTVCAudianceCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 18.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class PublicationEditorTVCAudianceCustomCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!

    @IBOutlet weak var audianceLabel: UILabel!
    
    var cellData: PublicationEditorTVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                self.audianceLabel.text = "Long Group Name"
                self.cellLabel.text = cellData.cellTitle
                
                if (cellData.userData as! Int) != 0 {
                    let goupeID = cellData.userData as! Int
                    // TO DO: find the name of the group based on it ID (goupeID) and set it as the label for audianceLabel
                    self.audianceLabel.text = "" // should be a name of groupe
                }
                
            }
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
