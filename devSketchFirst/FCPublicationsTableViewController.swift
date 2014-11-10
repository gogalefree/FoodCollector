//
//  FCPublicationsTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import UIKit
import Foundation

protocol FCPublicationsTVCDelegate {
    func didChosePublication(publication:FCPublication)
}


/// presents all Publication in a tableView.
/// must be sorted by distance from user location. nearest is first.


class FCPublicationsTableViewController : UITableViewController {
    
    var publications = [FCPublication]()
    var delegate:FCPublicationsTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

