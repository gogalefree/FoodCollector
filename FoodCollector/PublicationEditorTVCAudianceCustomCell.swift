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
                cellLabel.text = cellData.cellTitle
                if (cellData.userData as! Int) != 0 {
                    if let group = Group.fetchGroupWithId(cellData.userData as! Int) {
                        if let groupName = group.name {
                            audianceLabel.text = groupName.capitalizedString
                        }
                    }
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
