//
//  UserProfileTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 21/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class UserProfileTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserProfilePhotoCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        return 120
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("userProfilePhotoCell", forIndexPath: indexPath) as! UserProfilePhotoCell
        cell.delegate = self
        return cell
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
    
    
    //===========================================================================
    //   MARK: - Info Pop Over
    //===========================================================================

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
