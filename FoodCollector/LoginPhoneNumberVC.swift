//
//  LoginPhoneNumberVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 20.1.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class LoginPhoneNumberVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var cellPhoneField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var profilePicShadowView: UIView!
    @IBOutlet weak var userIdentityProviderName: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    let phoneNumberValidator = Validator()
    var tempPasteString = ""
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userIdentityProviderName.text = User.sharedInstance.userIdentityProviderUserName
        displayUserProfileImage()
        
        //createNumberPadAccessoryViewToolbar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        cellPhoneField.resignFirstResponder()
        cellPhoneField.text?.removeAll()
        self.view.endEditing(true)
    }
    
    func displayUserProfileImage() {
        profilePic.image = User.sharedInstance.userImage
        profilePic.layer.cornerRadius = CGRectGetWidth(profilePic.frame)/2
        profilePic.layer.masksToBounds = true
        
        profilePicShadowView.layer.cornerRadius = CGRectGetWidth(profilePic.frame)/2
        profilePicShadowView.layer.shadowRadius = 4.0
        profilePicShadowView.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        profilePicShadowView.layer.shadowOpacity = 0.3
    }
    
    @IBAction func chnageImageButtonClicked(sender: UIButton) {
        presentImagePickerActionSheet()
    }
    @IBAction func infoButtonClicked(sender: UIButton) {
        print("Info clicked!!!!!")
        presentInfoPopover()
    }
    
    @IBAction func startButtonClicked(sender: UIButton) {
        print("startButtonClicked")
        processPhoneNumberAndFinishLogin()
    }
    
    @IBAction func cancelRegistration(sender: UIButton) {
        print("cancelRegistration clicked")
        User.sharedInstance.setValueInUserClassProperty(true, forKey: UserDataKey.SkippedLogin)
        UIView.animateWithDuration(0.4) { () -> Void in
            self.navigationController?.view.removeFromSuperview()
            self.navigationController?.removeFromParentViewController()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // MARK: - Phone Number Methods
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
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
    
    func processPhoneNumberAndFinishLogin() {
        
        if(cellPhoneField.text!.isEmpty) {
            showPhoneNumberAllert()
            cellPhoneField?.resignFirstResponder()
        }
        else {
            if let onlyDigitsPhoneString = phoneNumberValidator.getValidPhoneNumber(cellPhoneField.text!) {
                
                User.sharedInstance.setValueInUserClassProperty(onlyDigitsPhoneString, forKey: UserDataKey.PhoneNumber)
                User.sharedInstance.setValueInUserClassProperty(true, forKey: UserDataKey.IsLoggedIn)
                UIView.animateWithDuration(0.6) { () -> Void in
                    self.navigationController?.view.removeFromSuperview()
                    self.navigationController?.removeFromParentViewController()
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
            processPhoneNumberAndFinishLogin()
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
                processPhoneNumberAndFinishLogin()
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //doneNumberPad()
        return true
    }
    
    //===========================================================================
    //   MARK: - Image Functions
    //===========================================================================
    
    func presentImagePickerActionSheet() {
        
        let actionSheet = UIAlertController(title: "", message:"", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let dissmissAction = UIAlertAction(title:kCancelButtonTitle, style: .Cancel) { (action) in
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let cameraAction = UIAlertAction(title:NSLocalizedString("Camera", comment:"camera button title "), style: UIAlertActionStyle.Default) { (action) in
            self.presentImagePickerController(.Camera)
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let photoLibraryAction = UIAlertAction(title:NSLocalizedString("Library", comment:"photo library button title"), style: UIAlertActionStyle.Default) { (action) in
            self.presentImagePickerController(.PhotoLibrary)
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(dissmissAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func presentImagePickerController (source: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = source
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if info[UIImagePickerControllerEditedImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.updateUserClassWithImage(image)
        }
    }
    
    func updateUserClassWithImage(userImage: UIImage) {
        User.sharedInstance.setValueInUserClassProperty(userImage, forKey: UserDataKey.Image)
        profilePic.image = User.sharedInstance.userImage
        let fullImageName = User.sharedInstance.getFullUserIamgeName()
        if (DeviceData.writeImage(userImage, imageName: fullImageName)) {
            User.sharedInstance.setValueInUserClassProperty(fullImageName, forKey: .ImageName)
        }
    }
    
    
    //===========================================================================
    //   MARK: - Info Pop Over
    //===========================================================================
    
    
    func presentInfoPopover(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let infoPopoverVC = storyboard.instantiateViewControllerWithIdentifier("InfoPopoverVC")
        let infoPopoverVCWidth =  CGFloat(222)
        let infoPopoverVCHeight = CGFloat(120)
        
        infoPopoverVC.popoverPresentationController?.delegate = self
        infoPopoverVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        infoPopoverVC.preferredContentSize = CGSizeMake(infoPopoverVCWidth, infoPopoverVCHeight)
        
        let infoPopoverPC = infoPopoverVC.popoverPresentationController
        infoPopoverPC?.delegate = self
        infoPopoverPC?.sourceView = infoButton
        infoPopoverPC?.sourceRect = infoButton.bounds
        infoPopoverPC?.permittedArrowDirections = UIPopoverArrowDirection.Down
        
        self.presentViewController(infoPopoverVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    

}


    
