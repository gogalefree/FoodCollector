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
    
    var section: Int?
    var minimumDate: PublicationEditorTVCCellData?
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if self.cellData != nil {
                self.cellDatePicker.setDate(cellData?.userData as! NSDate, animated: false)
                self.cellDatePicker.minimumDate = NSDate() //minimumDate?.userData as? NSDate
            }
        }
    }
    
    
    
    var delegate: CellInfoDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        addTapRecognizer()
        // Initialization code
    }
    
    func addTapRecognizer() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "datePickerTapped")
        tapRecognizer.delegate = self
        self.cellDatePicker.addGestureRecognizer(tapRecognizer)
    }
    
//    func datePickerTapped() {
//        if let delegate = self.delegate {
//            delegate.closeDatePicker()
//        }
//    }

    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
