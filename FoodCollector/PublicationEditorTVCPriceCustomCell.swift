//
//  PublicationEditorTVCPriceCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 10.6.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class PublicationEditorTVCPriceCustomCell: UITableViewCell , UITextFieldDelegate {
    
    let kNumberPadDoneTitle = String.localizedStringWithFormat("Done", "Done lable for button")
    let kNumberPadDismissTitle = String.localizedStringWithFormat("Cancel", "Cancel lable for button")
    let kAmountInputPlaceholder = String.localizedStringWithFormat("Free", "Publication editor price text field placeholder")

    @IBOutlet weak var amountInput: UITextField!
    @IBOutlet weak var currencySymbol: UILabel!
    
    let priceValidator = Validator()
    var didPastePriceValue = false
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if cellData != nil {
                if cellData?.cellTitle != "" {
                    self.amountInput.text = cellData!.cellTitle
                }
            }
        }
    }
    
    var section: Int?
    
    weak var delegate: CellInfoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        amountInput.delegate = self
        createNumberPadAccessoryViewToolbar()
    }
    
    private func createNumberPadAccessoryViewToolbar(){
        let buutonWidth = CGFloat(50)
        let numberPadAccessoryViewToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        
        let cancelButton = UIBarButtonItem(title: kNumberPadDismissTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissNumberPad))
        cancelButton.width = buutonWidth
        
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: kNumberPadDoneTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneNumberPad))
        doneButton.width = buutonWidth
        
        numberPadAccessoryViewToolbar.items = [cancelButton, flexibleSpaceButtonItem, doneButton]
        numberPadAccessoryViewToolbar.sizeToFit()
        
        amountInput?.inputAccessoryView = numberPadAccessoryViewToolbar
        
    }
    
    func dismissNumberPad() {
        amountInput.text = ""
        amountInput?.resignFirstResponder()
    }
    
    func doneNumberPad() {
        if let priceText = amountInput.text where !priceText.isEmpty {
            if !didPastePriceValue { // User typed the price using the keyboard
                cellData!.cellTitle = priceText
                if let doubleVelue = Double(priceText) {
                    cellData!.userData = doubleVelue
                }
            }
            
            if let delegate = self.delegate {
                delegate.updateData(cellData!, section: section!)
            }
        }
        else {
            dismissNumberPad()
        }
        
    }
    
    override func paste(sender: AnyObject?) {
        let pasteboard = UIPasteboard.generalPasteboard()
        if let tempPasteString = pasteboard.string {
            let priceString = priceValidator.getValidPriceValue(tempPasteString)
            if let price = Double(priceString) where Int(price) != 0 {
                cellData?.userData = price
                cellData?.cellTitle = priceString
                didPastePriceValue = true
            }
            else {
                cellData?.userData = 0.0
                cellData?.cellTitle = kAmountInputPlaceholder
            }
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
            didPastePriceValue = true
            let priceString = priceValidator.getValidPriceValue(string)
            if priceString != "" {
                if let price = Double(priceString) where Int(price) != 0 {
                    cellData?.userData = price
                    cellData?.cellTitle = priceString
                }
                else {
                    cellData?.userData = 0.0
                    cellData?.cellTitle = kAmountInputPlaceholder
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.placeholder = nil
        return true
    }
   
    func textFieldDidEndEditing(textField: UITextField) {
        let text = textField.text
        if text == "0" || text == "" {
            textField.text = ""
            textField.placeholder = kAmountInputPlaceholder
        }
    }
    

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
