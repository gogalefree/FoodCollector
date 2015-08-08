//
//  FCPublicationTypeOfPublicationEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 28/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

let kTypeOfCollectingFreePickUpTitle =
String.localizedStringWithFormat("איסוף חופשי", "the type of collecting method meaning free pickup")

let kTypeOfCollectingContactPublisherTitle =
String.localizedStringWithFormat("צור קשר עם המפרסם", "the type of collecting method meaning call publisher")

let typeOfCollectionEditorTitle = String.localizedStringWithFormat("צורת איסוף", "the editor title for enter type of collecting")

class FCPublicationTypeOfPublicationEditorVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionTypePicker: UIPickerView!
    
    var cellData = FCPublicationEditorTVCCellData()
    let digits = "0123456789"
    var onlyDigitsPhoneString = ""
    var isPhoneNumberValid = false

    
    let pickerData = [kTypeOfCollectingFreePickUpTitle , kTypeOfCollectingContactPublisherTitle]
    
    var didAnimateViewUp = false //used if the screen is 420 pxl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.textField.alpha = 0
        self.textField.text = ""
        self.title = typeOfCollectionEditorTitle
        configureInitialState()
        addTapGestureToPicker()
    }
    
    func configureInitialState() {
        
        if cellData.containsUserData {
          
            let typeOfCollectingDict = cellData.userData as! [String : AnyObject]
            let aRawValue = typeOfCollectingDict[kPublicationTypeOfCollectingKey] as! Int
            let typeOfcollecting = TypeOfCollecting(rawValue: aRawValue)
            if typeOfcollecting == TypeOfCollecting.ContactPublisher {
                
                let phoneNumber = typeOfCollectingDict[kPublicationContactInfoKey] as! String
                self.textField.text = phoneNumber
                showContactDetailsViews()
                self.collectionTypePicker.selectRow(1, inComponent: 0, animated: true)
            }
        }
    }
    
    @IBAction func saveButtonAction(sender: AnyObject) {
        
        //for iPhone 3.5 inch. animate the view down if needed
        if self.view.frame.height == 480 && self.didAnimateViewUp {
            animateViewDown()
        }
        
        let unwindSegueId = "unwindFromTypeOfCollectionEditorVC"
        let userChosenTypeOfCollectin = self.collectionTypePicker.selectedRowInComponent(0) + 1
        let typeOfCollecting = TypeOfCollecting(rawValue: userChosenTypeOfCollectin)!
        var contactInfo = ""
        if userChosenTypeOfCollectin == 1 {contactInfo = "no"}
        else {
            validtePhoneNumber(self.textField.text)
            if isPhoneNumberValid {
                contactInfo = onlyDigitsPhoneString
            }
        }
        var typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : userChosenTypeOfCollectin , kPublicationContactInfoKey : contactInfo]
        
        var cellTitle = ""
        
        switch typeOfCollecting {
       
        case .FreePickUp:
            cellTitle = kTypeOfCollectingFreePickUpTitle
        case .ContactPublisher:
            var callString = String.localizedStringWithFormat("התקשר: ", "means call to be added before a phone number")
            cellTitle = "\(callString) \(self.textField.text)"
        }
        
        self.cellData.containsUserData = true
        self.cellData.userData = typeOfCollectingDict
        self.cellData.cellTitle = cellTitle

        //here I can check if the number is valid
//        if isPhoneNumberValid {
//            self.performSegueWithIdentifier(unwindSegueId, sender: self)
//        }
//        else {
//            showPhoneNumberAllert()
//        }
        if userChosenTypeOfCollectin == 2 && !isPhoneNumberValid {
            showPhoneNumberAllert()
        }
        else {
            self.performSegueWithIdentifier(unwindSegueId, sender: self)

        }
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        switch row {
        case 0:
            hideContactDetailsViews()
        
        case 1:
            showContactDetailsViews()
        default:
            break
        }
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        println("picker view did select row")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = (textField.text as NSString).length + (string as NSString).length - range.length
        
        let digitsCharecterSet = NSCharacterSet(charactersInString: digits).invertedSet
        
        let components = string.componentsSeparatedByCharactersInSet(digitsCharecterSet)
        
        let filtered = join("", components)
        
        return string == filtered && newLength <= 10
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func hideContactDetailsViews() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.textField.alpha = 0
        })
    }
    
    func showContactDetailsViews() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.textField.alpha = 1
        })
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //if iPhone 3.5 inch - animate the view Up
       
        if self.view.frame.height == 480 {
            animateViewUp()
        }
        
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.view.frame.height == 480 && self.didAnimateViewUp {
            animateViewDown()
        }
        self.textField.resignFirstResponder()
    }
    
    func addTapGestureToPicker(){
        let tapGesture = UITapGestureRecognizer(target: self, action: "pickerViewTapped")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.delegate = self
        self.collectionTypePicker.addGestureRecognizer(tapGesture)
    }
    
    func pickerViewTapped() {
        if self.view.frame.height == 480 && self.didAnimateViewUp {
            animateViewDown()
        }
        self.textField.resignFirstResponder()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

    func animateViewUp() {
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            
            var newCenter = self.view.center
            newCenter.y -= 120
            self.view.center = newCenter
            
        }) { (Bool) -> Void in
            
            self.didAnimateViewUp = true
        }
    }
    
    func animateViewDown() {
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            var newCenter = self.view.center
            newCenter.y += 120
            self.view.center = newCenter
            
            }) { (Bool) -> Void in
                self.didAnimateViewUp = false
        }
    }
    
    func validtePhoneNumber(phoneNumber:String) {
        //println(">>> Start phone validation")
        //println("Phone: \(phoneNumber)")
        let legalCharsInPhone:Array<Character> = ["0", "1", "2", "3" ,"4", "5", "6", "7", "8", "9"]
        let twoDigitAreaCodes = ["02", "03", "04", "08", "09"]
        let threeDigitAreaCodes = ["072", "073", "074", "076", "077", "078", "050", "052", "053", "054", "055", "056", "058", "059"]
        // The list above is based on "http://he.wikipedia.org/wiki/קידומת_טלפון_בישראל"
        
        var isPhoneLengthCorrect = false
        var isAreaCodeCorrect = false
        
        // Remove all characters that are not numbers
        onlyDigitsPhoneString = "" // Reset variable to empty string
        for digitChar in phoneNumber {
            if contains(legalCharsInPhone, digitChar) {
                onlyDigitsPhoneString += String(digitChar)
            }
        }
        
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
        
        // If phone lenght is OK and area code is OK return true
        if isPhoneLengthCorrect && isAreaCodeCorrect {
            isPhoneNumberValid = true
        }
        else {
            isPhoneNumberValid = false
        }
    }
    
    func showPhoneNumberAllert() {
        //let alertTitle = String.localizedStringWithFormat("מספר טלפון לא תקין", "Alert title: Phone number is incorrect")
        //let alertMessage = String.localizedStringWithFormat("אנא בידקו שמספר הטלפון הינו בעל 9 או 10 ספרות ושהקידומת נכונה", "Alert message: Please check that the phone number has 9 or 10 digits and that the area code is correct")
        let alertTitle = String.localizedStringWithFormat("אופס...", "Alert title: Ooops...")
        let alertMessage = String.localizedStringWithFormat("נראה שמספר הטלפון לא תקין. אנא בידקו שהקלדתם נכון", "Alert message: It seems the phone number is incorrect. Please chaeck you have typed correctly.")
        let alertButtonTitle = String.localizedStringWithFormat("אישור", "Alert button title: OK")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: alertButtonTitle, style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}
