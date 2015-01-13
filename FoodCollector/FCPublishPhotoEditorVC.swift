//
//  FCPublishPhotoEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 03/01/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublishPhotoEditorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    var dataSource = [FCNewPublicationTVCCellData]()
//    var selectedDataObj : FCNewPublicationTVCCellData?
    var selectedTagNumber = 0
    var imagePicker: UIImagePickerController = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
