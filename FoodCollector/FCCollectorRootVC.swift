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
    var isPresentingPublicationDetailsView = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData:", name: kRecievedNewDataNotification, object: nil)
        self.publications = FCModel.sharedInstance.publications
        FCModel.sharedInstance.uiReadyForNewData = true
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

// MARK - new data sorter logic

extension FCCollectorRootVC {
    
    func didRecieveNewData(notification: NSNotification) {
        
        var publicationsToAdd = [FCPublication]()
        var publicationsToDelete = [FCPublication]()
        
        let toDeleteOperation = NSBlockOperation { () -> Void in
            publicationsToDelete = FCFetchedDataSorter.publicationsToDelete(self.publications)
        }
        
        let toAddQperation = NSBlockOperation { () -> Void in
            publicationsToAdd = FCFetchedDataSorter.publicationToAdd(self.publications)
        }
        
        toAddQperation.addDependency(toDeleteOperation)
        toAddQperation.completionBlock = {
            
            //update publicationDetailsView
            
            println("to add: \(publicationsToAdd.count)")
            println("to delete: \(publicationsToDelete.count)")
            
            if self.isPresentingPublicationDetailsView {
                self.updatePublicationDetailsViewWithNewData(publicationsToAdd)
            }
            
            //add new data to array
            
            //add new data to map
            
            //remove publicationsToDelete from map
            
            //remove publicationsToDelete from array
            
        }
        
        let sortQue = NSOperationQueue.mainQueue()
        sortQue.qualityOfService = .Background
        sortQue.addOperations([toDeleteOperation, toAddQperation], waitUntilFinished: false)
    }
    
    func updatePublicationDetailsViewWithNewData(publicationsToAdd: [FCPublication]) {
        
        //change this to the presented publication
        var presentedPublication = self.publications[1]
        
        if let updatedPresentingPublication = FCFetchedDataSorter.findPublicationToUpdate(publicationsToAdd, presentedPublication: presentedPublication){
            
            println("publication to update: \(updatedPresentingPublication.title)")
            //update the view
            //detailsView.publication = updatedPresentingPublication
            //detailsView.reloadSubViews
        }
    }

    
}

