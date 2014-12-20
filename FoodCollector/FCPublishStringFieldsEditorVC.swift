//
//  FCPublishStringFieldsEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 20/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import QuartzCore

class FCPublishStringFieldsEditorVC: UIViewController {

    var dataSource = [FCNewPublicationTVCCellData]()
    var selectedDataObj : FCNewPublicationTVCCellData?
    var selectedTagNumber = 0
    var showTextField = false
    
    @IBOutlet weak var pubTitleText: UITextField!
    
    @IBOutlet weak var pubSubTitleText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDataObj = getSelectedDataObject(selectedTagNumber)
        if showTextField {
            pubSubTitleText.alpha = 0.0
            if selectedTagNumber == 8 { // This is a phone number
                pubTitleText.text = selectedDataObj?.userData as String
                pubTitleText.keyboardType = UIKeyboardType.PhonePad
            }
            else {
                pubTitleText.text = selectedDataObj?.cellText
            }
            
            
        }
        else {
            pubTitleText.alpha = 0.0
            let frameColor = UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00)
            pubSubTitleText.layer.borderWidth = CGFloat(1.0)
            pubSubTitleText.layer.borderColor = frameColor.CGColor
            pubSubTitleText.layer.cornerRadius = CGFloat(5.0)
            pubSubTitleText.text = selectedDataObj?.cellText
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getSelectedDataObject(selectedTagNumber:Int) -> FCNewPublicationTVCCellData {
        return dataSource[selectedTagNumber]
        
        /*for dataObj in dataSource {
            if dataObj.identityTag == selectedTagNumber {
                return dataObj
            }
        }
        
        return FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, cellText: "", isObligatory: false, userData: String(), isSeperator: false, identityTag: selectedTagNumber)*/
    }
    
    
    
    private func updateData(){
        selectedDataObj!.userData = pubTitleText.text
        selectedDataObj!.containsUserData = true
        selectedDataObj!.isObligatory = true
    }
    
    private func updateDataSource(){
        println("updateDataSource")
        updateData()
        dataSource[selectedTagNumber] = selectedDataObj!
        println(dataSource[selectedTagNumber].userData)
    }
    
    
    /*
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
    //if (segue.identifier == "showPublicationTitleEditor") {
    //let pubEditorTVC = segue!.destinationViewController as FCPublicationEditorTVC
    updateDataSource()
    //pubEditorTVC.dataSource = dataSource
    //pubEditorTVC.isDataSourceEdited = true
    
    //}
    }*/
    
}
