//
//  PublicationEditorTVCTextFieldCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 14/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCTextFieldCustomCell: UITableViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var cellTextField: UITextField!
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if cellData != nil {
                if cellData?.userData as! String != "" {
                    self.cellTextField.text = cellData!.cellTitle
                }
                else {
                    self.cellTextField.placeholder = cellData!.cellTitle
                }
            }
        }
    }
    
    var section: Int?
    
    weak var delegate: CellInfoDelegate?
    //weak var asdasdasd: PhoneNumEditorDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellTextField.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        cellTextField.resignFirstResponder()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellTextField.text = ""
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // close the keyboard on Enter
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let delegate = self.delegate {
            delegate.closeDatePicker()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if !cellTextField.text!.isEmpty {
            cellData!.cellTitle = textField.text!
            cellData!.userData = textField.text!
            cellData!.containsUserData = true
            
            if let delegate = self.delegate {
                delegate.updateData(cellData!, section: section!)
            }
        }
    }

    
}
