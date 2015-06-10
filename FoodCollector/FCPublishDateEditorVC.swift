//
//  FCPublishDateEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 20/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

let startingDateEditorTitle = String.localizedStringWithFormat("תאריך התחלה", "the editor title for enter a starting date")
let endingDateTitle = String.localizedStringWithFormat("תאריך סיום", "the editor title for enter a publication ending date")
class FCPublishDateEditorVC: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var cellData = FCPublicationEditorTVCCellData()
    
    enum PickerState: Int {
        //values are in corelation with FCPublicationEditorTVC sections
        case StartingDate = 3
        case EndnigDate = 4
    }
    
    var state : PickerState = PickerState.StartingDate {
        didSet {
            switch state{
            case .StartingDate:
                self.title = startingDateEditorTitle
            
            case .EndnigDate:
                self.title = endingDateTitle
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.minimumDate = NSDate()
        self.datePicker.minuteInterval = 10
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        let date = self.datePicker.date
        self.cellData.containsUserData = true
        self.cellData.userData = date
        let celltitle = self.defineCellTitle()
        self.cellData.cellTitle = celltitle
    }
    
    func defineCellTitle() -> String {
        
        var title = ""
        var prefix = ""
        let dateString = FCDateFunctions.localizedDateStringShortStyle(self.datePicker.date)
        var timeString = FCDateFunctions.timeStringEuroStyle(self.datePicker.date)
        
        switch self.state {
        case .StartingDate:
            prefix = kPublishStartDatePrefix
        case .EndnigDate:
            prefix = kPublishEndDatePrefix
        }
        title = "\(prefix) \(dateString)   \(timeString)"
        return title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
