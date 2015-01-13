//
//  FCPublicationTypeOfPublicationEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 28/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationTypeOfPublicationEditorVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
//    var dataSource = [FCNewPublicationTVCCellData]()
//    var selectedDataObj : FCNewPublicationTVCCellData?
    var selectedTagNumber = 0
    var selectedValueInt = 1
    
    
    @IBOutlet weak var collectionTypePicker: UIPickerView!
    
    let pickerData = ["Free Pickup","Contact publisher"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        if let value = dataSource[selectedTagNumber].userData as? Int
//        {
//            if value == 2 {selectedValueInt = 2}
//        }
//        
//        collectionTypePicker.selectRow(selectedValueInt-1, inComponent: 0, animated: true)

        // Do any additional setup after loading the view.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValueInt = row + 1
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
