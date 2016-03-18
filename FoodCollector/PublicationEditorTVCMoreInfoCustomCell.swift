//
//  PublicationEditorTVCMoreInfoCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 18.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class PublicationEditorTVCMoreInfoCustomCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var cellText: UITextView!
    
    var cellData: PublicationEditorTVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                self.cellText.text = cellData.cellTitle
            }
        }
    }
    
    var section: Int?
    
    weak var delegate: CellInfoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellText.delegate = self
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //print("Return pressed")
            cellText.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("textViewDidEndEditing")
        if !cellText.text!.isEmpty {
            cellData!.cellTitle = textView.text!
            cellData!.userData = textView.text!
            cellData!.containsUserData = true
            
            if let delegate = self.delegate {
                delegate.updateData(cellData!, section: section!)
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
