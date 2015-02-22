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
let kActivityCenterTitle = String.localizedStringWithFormat("מרכז הפעילות","activity center navigation bar title")
let kCollctorTitle = String.localizedStringWithFormat("אוסף","collector root vc navigation bar title")

class FCCollectorRootVC : UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var showTableButton: UIBarButtonItem!
    @IBOutlet weak var trackUserButton: UIButton!
    
    @IBOutlet weak var blureView: UIView!
    var showTableButtonCopy:UIBarButtonItem!
    var publications = [FCPublication]()
    var isPresentingPublicationDetailsView = false
    var publicationDetailsTVC: FCPublicationDetailsTVC?
    var isPresentingActivityCenter = false
    var activityCenterTVC: UINavigationController?
    var activityCenterHiddenCenter = CGPointZero
    var activityCenterVisibleCenter = CGPointZero
    var tabbarVisibleCenter = CGPointZero
    var tabbarHiddenCenter = CGPointZero
    var tabbarDragCenter = CGPointZero
    var onceToken = 0
    var trackingUserLocation = false
    var locationManager = CLLocationManager()
    var didFinishInitialMapAnimation = false
    var didFailToRegisterPushNotifications = {
        NSUserDefaults.standardUserDefaults().boolForKey(kDidFailToRegisterPushNotificationKey)
        }()
    
    //MARK: - Location Manager setup
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
            
        case .Authorized , .AuthorizedWhenInUse :
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
        self.locationManager.startUpdatingLocation()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.headingFilter = 45
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        
        if self.trackingUserLocation{

//            if newHeading.headingAccuracy < 0 {return}
//       
//                var theHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
//                var newCamera = self.mapView.camera.copy() as MKMapCamera
//                newCamera.heading = theHeading
//                self.mapView.setCamera(newCamera, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
        if trackingUserLocation{
            
            self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
            var newCamera = self.mapView.camera.copy() as MKMapCamera
            newCamera.heading = self.mapView.userLocation.location.course
            self.mapView.setCamera(newCamera, animated: true)
            
        }
    }
    
    @IBAction func trackUserAction(sender: AnyObject) {
       
        self.trackingUserLocation = true
        self.blureView.animateToAlphaWithSpring(0.4, alpha: 0)
        self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = String.localizedStringWithFormat("אוסף", "collector map title")

        
        self.publications = FCModel.sharedInstance.publications
        registerForNSNotifications()
        configureMapView()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didDragMap:")
        panRecognizer.delegate = self
        self.mapView.addGestureRecognizer(panRecognizer)
        
        self.showTableButtonCopy = self.showTableButton as UIBarButtonItem
        
        if CLLocationManager.locationServicesEnabled() {
            self.setupLocationManager()
        }
        
        self.trackUserButton.layer.cornerRadius = self.trackUserButton.frame.size.width / 2
        self.blureView.layer.cornerRadius = self.blureView.frame.size.width / 2
        self.blureView.layer.borderWidth = 1
        self.blureView.layer.borderColor = UIColor.grayColor().CGColor

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.didFailToRegisterPushNotifications &&
            !NSUserDefaults.standardUserDefaults().boolForKey(kDidShowFailedToRegisterForPushAlertKey){
                
                let alertController = FCAlertsHandler.sharedInstance.alertWithDissmissButton("we can't inform you with new publications", aMessage: "to enable notifications: go to settings -> notifications -> food collector and enable push notifications")
                self.presentViewController(alertController, animated: true, completion: nil)
                
                //uncomment to show this message only once
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidShowFailedToRegisterForPushAlertKey)
        }
        
        dispatch_once(&onceToken, { () -> Void in
            FCModel.sharedInstance.uiReadyForNewData = true
            self.defineBarsCenterPoints()
        })
    }
    
    //MARK: - UI configuration
    
    func defineBarsCenterPoints() {
        
        tabbarDragCenter = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y + self.tabBarController!.tabBar.frame.size.height)
        
        tabbarVisibleCenter = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y)
        
        activityCenterVisibleCenter = CGPointMake(self.view.center.x - 0.1*self.view.center.x, self.view.center.y )
        activityCenterHiddenCenter = CGPointMake(-self.view.center.x, self.view.center.y )
        
        tabbarHiddenCenter = CGPointMake(self.tabBarController!.tabBar.center.x + CGRectGetWidth(self.view.frame), self.tabBarController!.tabBar.center.y)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.AdjustBarsCenterPointsTosize(size)
    }
    
    func AdjustBarsCenterPointsTosize(size: CGSize) {
        
        tabbarVisibleCenter = CGPointMake(size.width/2, size.height - self.tabBarController!.tabBar.bounds.size.height / 2)
        tabbarHiddenCenter = CGPointMake(size.width * 2, tabbarVisibleCenter.y)
        
        if self.isPresentingActivityCenter {
            self.tabBarController?.tabBar.center = self.tabbarHiddenCenter
        }
        
        activityCenterVisibleCenter = CGPointMake(0.9 * size.width / 2, size.height/2)
        activityCenterHiddenCenter = CGPointMake(-size.width, size.height/2)
        
        
    }

    
    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
       
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){

            if !isPresentingActivityCenter {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.hideTabbar()
            }
        }
        else if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            
            if !isPresentingActivityCenter {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.showTabbar()
                self.trackingUserLocation = false
                self.blureView.animateToAlphaWithSpring(0.4, alpha: 1)
            }
        }
    }
    
   
    func hideTabbar() {
        
        self.tabBarController!.tabBar.animateCenterWithSpring(0.4, center: self.tabbarDragCenter)
    }
    
    func showTabbar() {
        
        self.tabBarController!.tabBar.animateCenterWithSpring(0.4, center: self.tabbarVisibleCenter)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - Map View Delegate
    
    func configureMapView() {
        
        self.mapView.delegate = self
        self.mapView.addAnnotations(self.publications)
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
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
        annotationView!.image = FCIconFactory.smallIconForPublication(annotation as FCPublication)
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let annotation = view.annotation as MKAnnotation
        if annotation .isKindOfClass(MKUserLocation){
            return
        }
        
        let publication = view.annotation as FCPublication

        self.publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        
        self.publicationDetailsTVC?.publication = publication
        self.navigationController!.pushViewController(self.publicationDetailsTVC!, animated: true)

        self.reloadAnnotations()
        
      //  self.postOnSpotReport(publication)
    }
    
    
    // MARK: - ArrivedToSpotViewDelegate protocol
   
    func postOnSpotReport(publication: FCPublication) {

        var userInfo = [NSObject : AnyObject]()
        userInfo[kPublicationUniqueIdKey] = publication.uniqueId
        userInfo[kPublicationVersionKey] = publication.version

    NSNotificationCenter.defaultCenter().postNotificationName(kDidArriveOnSpotNotification, object: self, userInfo: userInfo)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - ActivityCenterLogic

extension FCCollectorRootVC {
    
    @IBAction func ShowActivityCenter(sender: AnyObject) {
        
        
        if !isPresentingActivityCenter {
            
            isPresentingActivityCenter = true
            
            self.activityCenterTVC = self.storyboard?.instantiateViewControllerWithIdentifier("activityCenterNav") as? UINavigationController//"FCActivityCenterTVC") as FCActivityCenterTVC!
        
            self.addChildViewController(self.activityCenterTVC!)
            self.activityCenterTVC!.view.frame = self.view.frame
            activityCenterTVC!.view.center = self.activityCenterHiddenCenter
            self.activityCenterTVC!.didMoveToParentViewController(self)
            self.mapView.addSubview(self.activityCenterTVC!.view)
            animateToActivityCenter()
        }
        else {
            //hide activity center
            
            isPresentingActivityCenter = false
            animateBcakFromActivityCenter()
        }
    }
    
    func animateToActivityCenter() {
        var tabbarCenter = self.tabBarController?.tabBar.center
        tabbarCenter?.x += self.view.bounds.width
        
        if let activityCenter = self.activityCenterTVC {
            
            self.blureView.animateToAlphaWithSpring(0.2, alpha: 0)
            
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                
                activityCenter.view.center = self.activityCenterVisibleCenter
                self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :UIColor.whiteColor()]
                self.tabBarController?.tabBar.center = self.tabbarHiddenCenter
                self.title = kActivityCenterTitle
                self.removeShowPublicationsTVCButton()
                }, completion: nil)
        }
    }
    
    func removeShowPublicationsTVCButton() {
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    func addShowPublicationsTVCButton() {
        self.showTableButton = self.showTableButtonCopy as UIBarButtonItem
        self.navigationItem.setRightBarButtonItem(self.showTableButton, animated: true)
    }
    
    func animateBcakFromActivityCenter() {
        
        if let activityCenter = self.activityCenterTVC {
            self.blureView.animateToAlphaWithSpring(0.5, alpha: 1)
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                
                activityCenter.view.center = self.activityCenterHiddenCenter
                self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
                self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName :UIColor.blackColor()]
                self.tabBarController?.tabBar.center = self.tabbarVisibleCenter
                self.title = kCollctorTitle
                self.addShowPublicationsTVCButton()
                
                }, completion: { (finished) -> Void in
                    
                    activityCenter.view.removeFromSuperview()
                    activityCenter.removeFromParentViewController()
                    self.activityCenterTVC = nil
            })
        }
    }
}


extension FCCollectorRootVC {
    
    // MARK: - new data from server logic

    func didRecieveNewData(notification: NSNotification) {
        
        self.reloadAnnotations()
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
    
    func reloadAnnotations() {
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mapView.removeAnnotations(self.publications)
            self.publications = FCModel.sharedInstance.publications
            self.mapView.addAnnotations(self.publications)
        })
    }
    
    func registerForNSNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAnnotations", name: "didFetchNewPublicationReportNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData:", name: kRecievedNewDataNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewPublication:", name: kRecievedNewPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationReport:", name: kRecivedPublicationReportNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
        
    }
}

