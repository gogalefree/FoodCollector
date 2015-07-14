//
//  FCPublicationDataInputVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
import UIKit
import Foundation
import CoreLocation

protocol FCPublicationDataInputDelegate {
    
    func didPickSubtitle(subtitle:String)
    func didPickDate(date:NSDate)
    func didPickTitle(title:String)
    func didPickTypeOfCollection(typeOfCollection: FCTypeOfCollecting ,withContactInfo contactinfo:String)
    func didPickAddress(address:String,withLocation coordinates:CLLocationCoordinate2D)
}

enum FCDataInputVCState {
    
    case TextField
    case TextView
    case StartingDate
    case EndingDate
    case PickTypeOfCollection
    
}


///
/// this class is responsible for picking:
/// 1. title
/// 2. description (subTitle)
/// 3. starting date
/// 4.ending date
/// 5. type of collection
///

class FCPublicationDataInputVC : UIViewController {
    
    @IBOutlet var datePicker:UIDatePicker!
    @IBOutlet var segmentedController:UISegmentedControl!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var textView:UITextView!
    @IBOutlet var textField:UITextField!
    @IBOutlet var doneButton:UIBarButtonItem!
    
    var delegate:FCPublicationDataInputDelegate!
    var dataInputVCState:FCDataInputVCState!
    
    
    func doneButtonClicked() {
        
    }
    
}

