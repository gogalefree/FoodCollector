//
//  PublicationEditorTVCStartEndDateCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 08/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCStartEndDateCustomCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var dateValueLabel: UILabel!
    
    var cellData: PublicationEditorVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                self.cellLabel.text = cellData.cellTitle
                
                let dateString = FCDateFunctions.localizedDateStringShortStyle(cellData.userData as! NSDate)
                let timeString = FCDateFunctions.timeStringEuroStyle(cellData.userData as! NSDate)
                self.dateValueLabel.text = "\(timeString)  \(dateString)"
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellLabel.text = ""
    }
    
}
