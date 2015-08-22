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


class PublicationEditorTVCPhoneNumEditorCustomCell: UITableViewCell, UITextFieldDelegate {
    
    
        
    
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
    
    var isPhoneNumberValid = false
    var onlyDigitsPhoneString = ""

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
        
        if(cellPhoneField.text.isEmpty) {
            showPhoneNumberAllert()
            cellPhoneField?.resignFirstResponder()
        }
        else {
            validtePhoneNumber(cellPhoneField.text)
        }
        
        
        
        if (isPhoneNumberValid) {
            
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
        //cellPhoneField?.resignFirstResponder()
    }
    
    func validtePhoneNumber(phoneNumber:String) {
        //println(">>> Start phone validation")
        //println("Phone: \(phoneNumber)")
        //let digits = "0123456789"
        
        
        let twoDigitAreaCodes = ["02", "03", "04", "08", "09"]
        let threeDigitAreaCodes = ["072", "073", "074", "076", "077", "078", "050", "052", "053", "054", "055", "056", "058", "059"]
        // The list above is based on "http://he.wikipedia.org/wiki/קידומת_טלפון_בישראל"
        
        var isPhoneLengthCorrect = false
        var isAreaCodeCorrect = false
        
        // Remove all characters that are not numbers
        onlyDigitsPhoneString = getOnlyDigitsNumber(phoneNumber)
        
        println("onlyDigitsPhoneString: \(onlyDigitsPhoneString)")
        
        // Check if phone lenght is 9 digits
        if count(onlyDigitsPhoneString) == 9 {
            isPhoneLengthCorrect = true
            // Check if a two digit area code is legal
            for areaCode in twoDigitAreaCodes {
                if onlyDigitsPhoneString.hasPrefix(areaCode) {
                    isAreaCodeCorrect = true
                    break
                }
                else {
                    isAreaCodeCorrect = false
                }
            }
        }
            // Check if phone lenght is 10 digits
        else if count(onlyDigitsPhoneString) == 10 {
            isPhoneLengthCorrect = true
            // Check if a three digit area code is legal
            for areaCode in threeDigitAreaCodes {
                if onlyDigitsPhoneString.hasPrefix(areaCode) {
                    isAreaCodeCorrect = true
                    break
                }
                else {
                    isAreaCodeCorrect = false
                }
            }
        }
        else {
            isPhoneLengthCorrect = false
        }
        
        // If phone lenght is OK and area code is OK set isPhoneNumberValid as true
        if isPhoneLengthCorrect && isAreaCodeCorrect {
            isPhoneNumberValid = true
        }
        else {
            isPhoneNumberValid = false
        }
    }
    
    func getOnlyDigitsNumber(numberString: String) -> String {
        // Remove all characters that are not numbers
        let legalCharsInPhone:Array<Character> = ["0", "1", "2", "3" ,"4", "5", "6", "7", "8", "9"]
        var tempPhoneString = "" // Reset variable to empty string
        for digitChar in numberString {
            if contains(legalCharsInPhone, digitChar) {
                tempPhoneString += String(digitChar)
            }
        }
        
        return tempPhoneString
    }
    
    func showPhoneNumberAllert() {

        let alertTitle = String.localizedStringWithFormat("אופס...", "Alert title: Ooops...")
        let alertMessage = String.localizedStringWithFormat("נראה שמספר הטלפון לא תקין. אנא בידקו שהקלדתם נכון", "Alert message: It seems the phone number is incorrect. Please chaeck you have typed correctly.")
        let alertButtonTitle = String.localizedStringWithFormat("אישור", "Alert button title: OK")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: alertButtonTitle, style: UIAlertActionStyle.Default,handler: nil))
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        
        //self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = getOnlyDigitsNumber(string)
        //cellPhoneField.reloadInputViews()
        return false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
