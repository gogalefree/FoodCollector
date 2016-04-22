//
//  UserProfileTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 21/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class UserProfileTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserProfilePhotoCellDelegate, UserProfileTextCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateButton: UIButton!
    
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    var blockingView: BlockingView!
    
    var newPhoneNumber  = ""
    var newUserName     = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        self.updateButton.enabled = false
        self.title = NSLocalizedString("Profile", comment: "the title of the profile vc")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        switch indexPath.row {
        case 0:
            return 120
        default:
            return 60
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfilePhotoCell", forIndexPath: indexPath) as! UserProfilePhotoCell
            cell.delegate = self
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileTextCell", forIndexPath: indexPath) as! UserProfileTextCell
            cell.type = .NameCell
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("userProfileTextCell", forIndexPath: indexPath) as! UserProfileTextCell
            cell.type = .PhoneNumberCell
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
            
        default:
            break
        }
        
        
        return UITableViewCell()
    }
    
    //MARK UserProfileTextCellDelegate
    
    func didRequestEditing(indexPath: NSIndexPath) {
        
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    func didEndEditing(text: String?, indexpath: NSIndexPath) {
    
        guard let data = text else {
            //present ooops message fo phone number
            presentPhoneNumberAllert()
            
            return
        }
        
        if !data.isEmpty {
            
            updateButton.enabled = true
            
            switch indexpath.row {
                case 1:
                    newUserName = data
                case 2:
                    newPhoneNumber = data
                default:
                    break
            }
        }
    }
    
    func presentPhoneNumberAllert() {
        
        let alertController = UIAlertController(title: kOopsAlertTitle, message: kPhoneNumberIncorrectAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
            alertController.addAction(UIAlertAction(title: kOKButtonTitle, style: UIAlertActionStyle.Cancel,handler: {(UIAlertAction) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            } ))
        
        self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //===========================================================================
    //   MARK: - Image Functions
    //===========================================================================
    
    func didRequestPhotoPicker() {
        self.presentImagePickerActionSheet()
    }
    
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
            self.updateImageCell(image)

            //update aws photo server
            let uploader = FCUserPhotoFetcher()
            uploader.uploadUserPhoto()
        }
    }
    
    func updateUserClassWithImage(userImage: UIImage) {
        User.sharedInstance.setValueInUserClassProperty(userImage, forKey: UserDataKey.Image)
        let fullImageName = User.sharedInstance.getFullUserIamgeName()
        if (DeviceData.writeImage(userImage, imageName: fullImageName)) {
            User.sharedInstance.setValueInUserClassProperty(fullImageName, forKey: .ImageName)
        }
    }
    
    func updateImageCell(image: UIImage) {
        
        let imageCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! UserProfilePhotoCell
        imageCell.animateNewImage(image)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    
    @IBAction func updateButtonAction(sender: AnyObject) {
        
        if blockingView == nil {
            blockingView = BlockingView(frame: self.view.bounds)
            self.view.addSubview(blockingView)
            self.view.bringSubviewToFront(blockingView)
        }
       
        self.blockingView.alpha = 1
        
        //save in user class
        if !newPhoneNumber.isEmpty {
            User.sharedInstance.setValueInUserClassProperty(newPhoneNumber, forKey: UserDataKey.PhoneNumber)
        }
        
        if !newUserName.isEmpty {
            User.sharedInstance.setValueInUserClassProperty(newUserName, forKey: UserDataKey.IdentityProviderUserName)
        }
        
        //update server
        //we only update the server with the phone number
        //the identity provider userName is saved localy so we have the original one in the server
        //publications and reports we'll be published under the new user name
        
        FCModel.sharedInstance.foodCollectorWebServer.updateUserProfile { (success) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if success {
             
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                else {
                
                    self.blockingView.alpha = 0
                    let title = NSLocalizedString("Could not update your profile", comment: "alert title")
                    let message = NSLocalizedString("Try again later", comment: "alert message")
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(title, aMessage: message)
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                
                }
            })
        }
    }
}
