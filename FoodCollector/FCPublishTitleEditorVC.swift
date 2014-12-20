//
//  FCPublishTitleEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 18/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublishTitleddddddEditorVC: UIViewController {
    
    var dataSource = [FCNewPublicationTVCCellData]()
    var selectedDataObj : FCNewPublicationTVCCellData?
    var selectedTagNumber = 0
    var showTitle = true

    @IBOutlet weak var pubTitleText: UITextField!
    
    @IBOutlet weak var pubSubTitleText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDataObj = getSelectedDataObject(selectedTagNumber)
        if showTitle {
            pubSubTitleText.alpha = 0.0
            pubTitleText.text = selectedDataObj?.cellText
        }
        else {
            pubTitleText.alpha = 0.0
            pubSubTitleText.text = selectedDataObj?.cellText
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getSelectedDataObject(selectedTagNumber:Int) -> FCNewPublicationTVCCellData {
        for dataObj in dataSource {
            if dataObj.identityTag == selectedTagNumber {
                return dataObj
            }
        }
        
        return FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, cellText: "", isObligatory: false, userData: String(), isSeperator: false, identityTag: selectedTagNumber)
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
