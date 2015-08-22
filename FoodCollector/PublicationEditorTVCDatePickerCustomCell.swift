//
//  PublicationEditorTVCDatePickerCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 15/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCDatePickerCustomCell: UITableViewCell {
    
    @IBOutlet weak var cellDatePicker: UIDatePicker!
    
    @IBAction func cellDatePicker(sender: UIDatePicker) {
        cellData!.userData = sender.date
        cellData!.containsUserData = true
        
        if let delegate = self.delegate {
            delegate.updateData(cellData!, section: section!)
        }
        
    }
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if let cellDatePicker = self.cellData {
                self.cellDatePicker.setDate(cellData?.userData as! NSDate, animated: false)
            }
        }
    }
    
    var section: Int?
    
    var delegate: CellInfoDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
