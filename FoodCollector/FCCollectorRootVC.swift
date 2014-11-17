//
//  FCCollectorRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation


///
/// collector user story main VC.
///
class FCCollectorRootVC : UIViewController,FCPublicationDetailsViewDelegate,FCArrivedToSpotViewDelegate,FCPublicationsTVCDelegate {
    
    @IBOutlet var mapView:MKMapView!
    var onSpotPublicationReport:FCOnSpotPublicationReport?
    var publications = [FCPublication]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData:", name: kRecievedNewDataNotification, object: nil)
        self.publications = FCModel.sharedInstance.publications
        FCModel.sharedInstance.uiReadyForNewData = true
    }
    
    func didRecieveNewData(notification: NSNotification) {

        var publicationToDelete = FCFetchedDataSorter.publicationsToDelete(self.publications)
        var publicationsToAdd = FCFetchedDataSorter.publicationToAddAndUpdate(self.publications)
        
    }
    
    
    // MARK: - PublicationDetailsViewDelegate protocol
    
    func publicationDetailsViewDidCancel() {
        
    }
    
    func didRequestNavigationForPublication(publication:FCPublication) {
        
    }
    
    func didOrderCollectionForPublication(order:FCOrderCollectionForPublication) {
        
    }
    
    // MARK: - ArrivedToSpotViewDelegate protocol
    
    func didReport(report:FCOnSpotPublicationReport,forPublication publication:FCPublication) {
        
    }
    
    
    
    // MARK: - PublicationsTVCDelegate protocol
    
    func didChosePublication(publication:FCPublication) {
        
    }
    
}

