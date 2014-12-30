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

let kDidShowFailedToRegisterForPushAlertKey = "didShowFailedToRegisterForPushMessage"


class FCCollectorRootVC : UIViewController,FCPublicationDetailsViewDelegate,FCArrivedToSpotViewDelegate,FCPublicationsTVCDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var showTableButton: UIBarButtonItem!
    
    var onSpotPublicationReport:FCOnSpotPublicationReport?
    var publications = [FCPublication]()
    var isPresentingPublicationDetailsView = false
    
    var didFailToRegisterPushNotifications = {
        NSUserDefaults.standardUserDefaults().boolForKey(kDidFailToRegisterPushNotificationKey)
        }()
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = String.localizedStringWithFormat("Collect", "the collector main screen title")
        
        self.publications = FCModel.sharedInstance.publications
        registerForNSNotifications()
        configureMapView()
        FCModel.sharedInstance.uiReadyForNewData = true
    }
    
    //MARK: - Map View Delegate
    
    func configureMapView() {
        
        self.mapView.delegate = self
        self.mapView.addAnnotations(self.publications)
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let reusableIdentifier = "annotationViewID"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusableIdentifier) as? FCAnnotationView
        
        if annotationView == nil {
            annotationView = FCAnnotationView(annotation: annotation, reuseIdentifier: reusableIdentifier)
        }
        
        annotationView!.imageForPublication(annotation as FCPublication)
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        let publication = view.annotation as FCPublication
        println(publication.title)
    }
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        println("will change region")
        //        if !self.eventDetailsViewHidden {
        //            self.hideEventDetailsView()
        //        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        println("did change region")
        
    }
    
    
    // MARK: - PublicationDetailsViewDelegate protocol
    
    func publicationDetailsViewDidCancel() {
        
    }
    
    func didRequestNavigationForPublication(publication:FCPublication) {
        
    }
    
    func didOrderCollectionForPublication(publication: FCPublication) {
        
    }
    
    // MARK: - ArrivedToSpotViewDelegate protocol
    
    func didReport(report:FCOnSpotPublicationReport,forPublication publication:FCPublication) {
        
    }
    
    
    
    // MARK: - PublicationsTVCDelegate protocol
    
    func didChosePublication(publication:FCPublication) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.didFailToRegisterPushNotifications &&
            !NSUserDefaults.standardUserDefaults().boolForKey(kDidShowFailedToRegisterForPushAlertKey){
                
                let alertController = FCAlertsHandler.sharedInstance.alertWithDissmissButton("we can't inform you with new publications", aMessage: "to enable notifications: do to settings -> notifications -> food collector and enable push notifications")
                self.presentViewController(alertController, animated: true, completion: nil)
                
                //uncomment to show this message only once
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidShowFailedToRegisterForPushAlertKey)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK - new data from server logic

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
            
            println("to add: \(publicationsToAdd.count)")
            println("to delete: \(publicationsToDelete.count)")
            
            self.publications = FCModel.sharedInstance.publications
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.removeAnnotations(publicationsToDelete)
                self.mapView.addAnnotations(publicationsToAdd)
                if self.isPresentingPublicationDetailsView {
                    self.updatePublicationDetailsViewWithNewData(publicationsToAdd)
                }
            })
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
    
    //MARK - new data from push notification.
    //these notifications are posted ny FCModel after handling remote notification events
    
    func didRecieveNewPublication(notification: NSNotification) {
        
        let recivedPublication = FCModel.sharedInstance.publications.last!
        self.deleteOldVersionsOf(recivedPublication)
        self.mapView.addAnnotation(recivedPublication)
        
        
        //change this to the presented publication
        var presentedPublication = self.publications[1]
        if self.isPresentingPublicationDetailsView {
            if presentedPublication.uniqueId == recivedPublication.uniqueId &&
                presentedPublication.version < recivedPublication.version {
                    println("updating view with new publication")
                    //update the view
                    //detailsView.publication = updatedPresentingPublication
                    //detailsView.reloadSubViews
            }
        }
        
        self.publications = FCModel.sharedInstance.publications
    }
    
    func deleteOldVersionsOf(recievedPublication: FCPublication) {
        
        if recievedPublication.version > 1 {
            
            let removeAnnotationQperation = NSBlockOperation { () -> Void in
                
                for annotation in self.mapView.annotations {
                    
                    if !annotation.isKindOfClass(FCPublication) {continue}
                    
                    var thePublication = annotation as FCPublication
                    if thePublication.uniqueId == recievedPublication.uniqueId &&
                        thePublication.version < recievedPublication.version {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.mapView.removeAnnotation(thePublication)
                            })
                    }
                }
            }
            let removeAnnotationQue = NSOperationQueue.mainQueue()
            removeAnnotationQue.qualityOfService = .Background
            removeAnnotationQue.addOperations([removeAnnotationQperation], waitUntilFinished: false)
        }
    }
    
    
    func didDeletePublication(notification: NSNotification) {
        
        let toDeleteIdentifier = FCUserNotificationHandler.sharedInstance.recivedtoDelete.last!
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            if let publicationToDelete = self.publicationWithIdentifier(toDeleteIdentifier) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mapView.removeAnnotation(publicationToDelete)
                })
            }
        })
        
        
        //change this to the presented publication
        var presentedPublication = self.publications[1]
        //check if it's being displayed
        if self.isPresentingPublicationDetailsView &&
            presentedPublication.uniqueId == toDeleteIdentifier.uniqueId &&
            presentedPublication.version == toDeleteIdentifier.version {
                //show Publication deleted view
        }
        
        self.publications = FCModel.sharedInstance.publications
        
    }
    
    func didRecievePublicationReport(notification: NSNotification) {
        var (identifier, report ) = FCUserNotificationHandler.sharedInstance.recivedReports.last!
        
        //we need to check if the report belongs to the presented publication to refresh it
        //change this to the presented publication
        var presentedPublication = self.publications[0]
        
        if self.isPresentingPublicationDetailsView &&
            presentedPublication.uniqueId == identifier.uniqueId &&
            presentedPublication.version == identifier.version {
                
                //self.publicationDetailsView.reloadReports
        }
        
    }
    
    func didRecievePublicationRegistration(notification: NSNotification) {
        
        var registration = FCUserNotificationHandler.sharedInstance.recievedRegistrations.last!
        
        //the registration was added to the publication
        //we need to check if the registration belongs to the presented detailsView
        
        //change this to the presented publication
        var presentedPublication = self.publications[0]
        
        if presentedPublication.uniqueId == registration.identifier.uniqueId &&
            presentedPublication.version == registration.identifier.version {
                //self.publicationDetailsView.reloadRegistrations
                println("updated pubication registration \(presentedPublication.registrationsForPublication.count)")
        }
        
    }
    
    func publicationWithIdentifier(identifier: PublicationIdentifier) -> FCPublication? {
        var requestedPublication: FCPublication?
        for publication in self.publications {
            if publication.uniqueId == identifier.uniqueId &&
                publication.version == identifier.version{
                    requestedPublication = publication
            }
        }
        return requestedPublication
    }
    
    func registerForNSNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData:", name: kRecievedNewDataNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewPublication:", name: kRecievedNewPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationReport:", name: kRecivedPublicationReportNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
        
    }
}

