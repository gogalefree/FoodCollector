//
//  FCPublishDateEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 20/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublishDateEditorVC: UIViewController {
    
//    var dataSource = [FCNewPublicationTVCCellData]()
//    var selectedDataObj : FCNewPublicationTVCCellData?
    var selectedTagNumber = 0

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        selectedDataObj = getSelectedDataObject(selectedTagNumber)
//        datePicker.setDate(selectedDataObj?.userData as NSDate, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    private func getSelectedDataObject(selectedTagNumber:Int) -> FCNewPublicationTVCCellData {
//        if let date = dataSource[selectedTagNumber].userData as? NSDate {
//            return dataSource[selectedTagNumber]
//        }
//        dataSource[selectedTagNumber].userData = NSDate()
//        return dataSource[selectedTagNumber]
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
