//
//  FCPublicationAddressPickerVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//
import UIKit
import CoreLocation


///
/// publication address picker.
/// communicates with google location autocomplete api via appWebserver

class FCPublicationAddressPickerVC : UIViewController {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var segmentedView:UISegmentedControl!
    
    var publicationDataInputDelegate:FCPublicationDataInputDelegate!
    
    
    func didPickAddress(address:String,withCoordinates coordinates:CLLocationCoordinate2D) {
    }
    
}

