//
//  PublicationEditorTVCPhoneNumEditorCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 15/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCPhoneNumEditorCustomCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var cellPhoneField: UITextField!
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if self.cellData != nil {
                let typeOfPublicationRawValue = cellData!.userData.objectForKey(kPublicationTypeOfCollectingKey) as! Int
                var cellTitle = cellData!.userData.objectForKey(kPublicationContactInfoKey) as! String
                if (typeOfPublicationRawValue == 2){
                    if (cellTitle != "") {
                        if cellTitle == "no" {cellTitle = ""}
                        self.cellPhoneField.text = cellTitle
                    }
                }
            }
        }
    }
    
    var section: Int?
    
    weak var delegate: CellInfoDelegate?
    
    let phoneNumberValidator = Validator()
        
    var tempPasteString = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellPhoneField.delegate = self
        createNumberPadAccessoryViewToolbar()
        
        
    }
    
    private func createNumberPadAccessoryViewToolbar(){
        let buutonWidth = CGFloat(50)
        let numberPadAccessoryViewToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        
        let cancelButton = UIBarButtonItem(title: kCancelButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissNumberPad")
        cancelButton.width = buutonWidth
        
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: kDoneButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "doneNumberPad")
        doneButton.width = buutonWidth
        
        numberPadAccessoryViewToolbar.items = [cancelButton, flexibleSpaceButtonItem, doneButton]
        numberPadAccessoryViewToolbar.sizeToFit()
        
        cellPhoneField?.inputAccessoryView = numberPadAccessoryViewToolbar
        
    }
    
    func dismissNumberPad() {
        
        cellPhoneField?.resignFirstResponder()
    }
    
    func doneNumberPad() {
        
        if(cellPhoneField.text!.isEmpty) {
            showPhoneNumberAllert()
            cellPhoneField?.resignFirstResponder()
        }
        else {
            if let onlyDigitsPhoneString = phoneNumberValidator.getValidPhoneNumber(cellPhoneField.text!) {
                
                let typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : 2 , kPublicationContactInfoKey : onlyDigitsPhoneString]
                cellData!.userData = typeOfCollectingDict
                cellData!.containsUserData = true
                
                if let delegate = self.delegate {
                    delegate.updateData(cellData!, section: section!)
                }
            }
            else {
                showPhoneNumberAllert()
            }
            
        }
    }
    
    
    func showPhoneNumberAllert() {

        let alertController = UIAlertController(title: kOopsAlertTitle, message: kPhoneNumberIncorrectAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: kOKButtonTitle, style: UIAlertActionStyle.Default,handler: nil))
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func paste(sender: AnyObject?) {
        let pasteboard = UIPasteboard.generalPasteboard()
        if let tempPasteString = pasteboard.string {
            cellPhoneField.text = phoneNumberValidator.getValidPhoneNumber(tempPasteString)
            cellPhoneField.resignFirstResponder()
            doneNumberPad()
        }
    }
    
    // Catch the string value and store in a temp var when the user pasted a string fomr clipboard.
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // When typing into the text field each keyboard type adds 1 character.
        // When pasting into the text field it is usually more than one character.
        if (string.characters.count < 2) { // Regular typing action
            return true
        }
        else { // Paste action
            if (cellPhoneField.text != "") {
                cellPhoneField.text = phoneNumberValidator.getValidPhoneNumber(string)
                cellPhoneField.resignFirstResponder()
                doneNumberPad()
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let delegate = self.delegate {
            delegate.closeDatePicker()
        }
        
        return true
    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //doneNumberPad()
        return true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // This method is called when a user clicks in a table outside this cell.
        // In this case we need to hide the keyboard and check if the phone number
        // has the correct format.
        
        //This method is called many times in response to changes in the table.
        // We want to call doneNumberPad() from this method only if the
        // phone number textfield is NOT empty!
        //if !(cellPhoneField.text!.isEmpty) {
        //    doneNumberPad()
        //}
        
        
        // Configure the view for the selected state
    }
    
//    func dismissKeyboard(){
//         cellPhoneField.resignFirstResponder()
//    }
    
}

//===========================================================================
//   MARK: - Protocols
//===========================================================================
//protocol PhoneNumEditorDelegate :NSObjectProtocol{
//    func dismissKeyboard()
//}

