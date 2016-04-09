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

let kShouldShowFailedToRegisterForPushAlertKey = "didShowFailedToRegisterForPushMessage"
let kActivityCenterTitle = NSLocalizedString("Activity Center", comment:"Activity center navigation bar title")
let kCollctorTitle = NSLocalizedString("Pickup", comment:"Collector home page navigation bar title")

protocol CollectorVCSlideDelegate: NSObjectProtocol {
    func collectorVCWillSlide()
}

class FCCollectorRootVC : UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, UIGestureRecognizerDelegate, FCPublicationsTVCDelegate{
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var showTableButton: UIBarButtonItem!
    @IBOutlet weak var trackUserButton: UIButton!
    
    @IBOutlet weak var blureView: UIView!
    weak var delegate: CollectorVCSlideDelegate!

    var publications = [Publication]()
    var annotations = [FDAnnotation]()
    var isPresentingNewDataMessageView = false
    var panStartingPoint: CGPoint!
    var publicationDetailsTVC: PublicationDetailsVC?
    var isPresentingActivityCenter = false
    var trackingUserLocation = false
    var locationManager = CLLocationManager()
    var initialLaunch = true

    
    //MARK: - Location Manager setup
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
            
        case .AuthorizedWhenInUse :
            self.setupLocationManager()
        default :
            break
        }
    }

    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 2.5
        if !CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.headingFilter = 45
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        if trackingUserLocation{
            
            self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
            let newCamera = self.mapView.camera.copy() as! MKMapCamera
            newCamera.heading = self.mapView.userLocation.location!.course
            self.mapView.setCamera(newCamera, animated: true)
            
        }
    }
    
    //MARK: - Track button action
    @IBAction func trackUserAction(sender: AnyObject) {
       
        self.trackingUserLocation = true
        self.blureView.animateToAlphaWithSpring(0.4, alpha: 0)
        self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = NSLocalizedString("Pickup", comment:"Collector map title")
        self.publications = FCModel.sharedInstance.publications
        registerForNSNotifications()
        configureMapView()
        configureTrackButton()
        addPanRecognizer()
        self.setupLocationManager()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if initialLaunch {
     

            //we set the map to center on user's location. if the location manager has no location, we set the map's center to Tel-Aviv
            var userCoordinadets = FCModel.sharedInstance.userLocation.coordinate
            if Int(userCoordinadets.longitude) == 0 || Int(userCoordinadets.latitude) == 0 {
               
                userCoordinadets.latitude = 32.0539
                userCoordinadets.longitude = 34.785227
            }
            
            let span   = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
            let region = MKCoordinateRegion(center: userCoordinadets, span: span)
            mapView.setRegion(region, animated: false)
            initialLaunch = false
            
            FCModel.sharedInstance.uiReadyForNewData = true
        }
    }
    
    
    //MARK: - UI configuration
    
    func addPanRecognizer() {
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didDragMap:")
        panRecognizer.delegate = self
        self.mapView.addGestureRecognizer(panRecognizer)
    }
    
    func configureTrackButton() {
        
        self.trackUserButton.layer.cornerRadius = self.trackUserButton.frame.size.width / 2
        self.blureView.layer.cornerRadius = self.blureView.frame.size.width / 2
        self.blureView.layer.borderWidth = 1
        self.blureView.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    
    func didDragMap(gestureRecognizer: UIPanGestureRecognizer) {
       
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){

            self.panStartingPoint = gestureRecognizer.translationInView(self.mapView)
            if !isPresentingActivityCenter {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        }
        else if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            
            if !isPresentingActivityCenter {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.trackingUserLocation = false
                self.blureView.animateToAlphaWithSpring(0.4, alpha: 1)
            }
            else {
                //hide activty center
                ShowActivityCenter(self)
            }
            
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentPublicationsTVC" {
            let navController = segue.destinationViewController as! UINavigationController
            let tableViewController = navController.viewControllers[0] as! FCPublicationsTableViewController
            tableViewController.delegate = self
        }
    }
    
    //MARK: - FCPublicationsTVC Delegate
    
    func didRequestActivityCenter() {
        self.ShowActivityCenter(self)
    }
    
    @IBAction func unwindFromTableView(segue: UIStoryboardSegue) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Map View Delegate
    
    func configureMapView() {
        
        self.mapView.delegate = self
        let annotations = self.makeAnnotations()
        self.mapView.addAnnotations(annotations)
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    }
    
    func makeAnnotations() -> [FDAnnotation] {
       
        var annotations = [FDAnnotation]()
        
        for publication in self.publications {
            let annotation =  FDAnnotation(publication: publication)
            annotations.append(annotation)
        }
        self.annotations = annotations
        return annotations
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let reusableIdentifier = "annotationViewID"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusableIdentifier) as? FCAnnotationView
        
        if annotationView == nil {
            annotationView = FCAnnotationView(annotation: annotation, reuseIdentifier: reusableIdentifier)
        }
        annotationView?.image = UIImage(named: "Pin_Map_Marker") // FCIconFactory.smallIconForPublication(annotation as! FCPublication)
        annotationView?.canShowCallout = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        annotationView?.calloutOffset = CGPoint(x: 0, y: -5)
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation
        if annotation!.isKindOfClass(MKUserLocation){
            return
        }
        
       
        //  self.postOnSpotReport(publication)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as? FDAnnotation
        guard let publication = annotation?.publication else {return}
        self.presentPublicationDetailsTVC(publication)
    }
    
    func presentPublicationDetailsTVC(publication:Publication) {
        
        self.publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublicationDetailsVC") as? PublicationDetailsVC
        self.publicationDetailsTVC?.publication = publication
        let state :PublicationDetailsTVCViewState = publication.isUserCreatedPublication!.boolValue ? .Publisher : .Collector
        self.publicationDetailsTVC?.setupWithState(state, caller: .MyPublications, publication: publication)
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
        let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
        self.navigationController!.presentViewController(nav, animated: true, completion: nil)
    }
    
    func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - ActivityCenterLogic

extension FCCollectorRootVC {
    
    @IBAction func ShowActivityCenter(sender: AnyObject) {
        
        self.isPresentingActivityCenter = !self.isPresentingActivityCenter
        if self.delegate != nil {
            self.delegate.collectorVCWillSlide()
        }
    }
}

// MARK: - new data from server logic

extension FCCollectorRootVC {
    
    func didRecieveNewData(notification: NSNotification) {
        
        self.reloadAnnotations()
    }
    

    //MARK: - newDataMessageViewDelegate
    //called when a user tapped show action in newDataMessageView
    func showNewPublicationDetails(publication: Publication) {

       // self.hideNewDataMessageView()
        self.presentPublicationDetailsTVC(publication)
    }
    
    
    func didDeletePublication(notification: NSNotification) {

        self.reloadAnnotations()
    }
    
    
    func reloadAnnotations() {
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            self.mapView.removeAnnotations(self.annotations)
            self.publications = FCModel.sharedInstance.publications
            let annotations = self.makeAnnotations()
            self.mapView.addAnnotations(annotations)
        })
    }
    
    
    func registerForNSNotifications() {
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAnnotations", name: "didFetchNewPublicationReportNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAnnotations", name: kReloadDataNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData:", name: kRecievedNewDataNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAnnotations", name: kRecievedNewPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
                

   //     NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentNotificationsFromWebFetch", name: kDidPrepareNotificationsFromWebFetchNotification, object: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //
        //        if self.trackingUserLocation{
        //
        //            if newHeading.headingAccuracy < 0 {return}
        //
        //                var theHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        //                var newCamera = self.mapView.camera.copy() as MKMapCamera
        //                newCamera.heading = theHeading
        //                self.mapView.setCamera(newCamera, animated: true)
        //        }
    }

    
}

