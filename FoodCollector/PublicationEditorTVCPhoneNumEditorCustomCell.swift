//
//  PublicationEditorTVCPhoneNumEditorCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 15/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

let kPhoneNumberPadDoneTitle = String.localizedStringWithFormat("סיום", "Done lable for button")
let kPhoneNumberPadDismissTitle = String.localizedStringWithFormat("ביטול", "Cancel lable for button")


class PublicationEditorTVCPhoneNumEditorCustomCell: UITableViewCell {
    
    
        
    
    @IBOutlet weak var cellPhoneField: UITextField!
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if let cellPhoneField = self.cellData {
                let typeOfPublicationRawValue = cellData!.userData.objectForKey(kPublicationTypeOfCollectingKey) as! Int
                let cellTitle = cellData!.userData.objectForKey(kPublicationContactInfoKey) as! String
                if (typeOfPublicationRawValue == 2){
                    if (cellTitle != "") {
                        self.cellPhoneField.text = cellTitle
                    }
                }
            }
        }
    }
    
    var section: Int?
    
    var delegate: CellInfoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        createNumberPadAccessoryViewToolbar()
        
    }
    
    private func createNumberPadAccessoryViewToolbar(){
        let buutonWidth = CGFloat(50)
        let numberPadAccessoryViewToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        
        let cancelButton = UIBarButtonItem(title: kPhoneNumberPadDismissTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissNumberPad")
        cancelButton.width = buutonWidth
        
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: kPhoneNumberPadDoneTitle, style: UIBarButtonItemStyle.Done, target: self, action: "doneNumberPad")
        doneButton.width = buutonWidth
        
        numberPadAccessoryViewToolbar.items = [cancelButton, flexibleSpaceButtonItem, doneButton]
        numberPadAccessoryViewToolbar.sizeToFit()
        
        cellPhoneField?.inputAccessoryView = numberPadAccessoryViewToolbar
        
    }
    
    func dismissNumberPad() {
        cellPhoneField.text = ""
        cellPhoneField?.resignFirstResponder()
    }
    
    func doneNumberPad() {
        if !cellPhoneField.text!.isEmpty {
            //cellData!.cellTitle = cellPhoneField.text
            //cellData!.userData = cellPhoneField.text
            let contactDetails = cellPhoneField.text
            
            let typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : 2 , kPublicationContactInfoKey : contactDetails]
            cellData!.userData = typeOfCollectingDict
            cellData!.containsUserData = true
            
            
            if let delegate = self.delegate {
                delegate.updateData(cellData!, section: section!)
            }
            
        }
        cellPhoneField?.resignFirstResponder()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
