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


class FCPublicationsTableViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var publications = [FCPublication]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.publications = FCModel.sharedInstance.publications
        
        self.publications = self.publications.sorted({ (a1, a2) -> Bool in
            let one : FCPublication = a1
            let two : FCPublication = a2
            return one.distanceFromUserLocation < two.distanceFromUserLocation
            
            
        })
        
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCellWithIdentifier("publicationTableViewCell", forIndexPath: indexPath) as FCPublicationsTVCell
        let publication = self.publications[indexPath.row] as FCPublication
        cell.publication = publication
        return cell
        
    }
    
}

