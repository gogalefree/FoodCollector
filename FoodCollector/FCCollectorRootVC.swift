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
let kActivityCenterTitle = String.localizedStringWithFormat("מרכז הפעילות","activity center navigation bar title")
let kCollctorTitle = String.localizedStringWithFormat("איסוף","collector root vc navigation bar title")

protocol CollectorVCSlideDelegate: NSObjectProtocol {
    func collectorVCWillSlide()
}

class FCCollectorRootVC : UIViewController, MKMapViewDelegate , CLLocationManagerDelegate, UIGestureRecognizerDelegate, FCPublicationsTVCDelegate, FCNewDataMessageViewDelegate{
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var showTableButton: UIBarButtonItem!
    @IBOutlet weak var trackUserButton: UIButton!
    
    @IBOutlet weak var blureView: UIView!
    @IBOutlet weak var newPublicationMessageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var newPublicationMessageView: FCCollectorNewDataMessageView!
    
    weak var delegate: CollectorVCSlideDelegate!

    var publications = [FCPublication]()
    var isPresentingNewDataMessageView = false
    var panStartingPoint: CGPoint!
    let kNewDataMessageViewTopConstant: CGFloat = 13
    var publicationDetailsTVC: FCPublicationDetailsTVC?
    var isPresentingActivityCenter = false
    var tabbarVisibleCenter = CGPointZero
    var tabbarDragCenter = CGPointZero
    var trackingUserLocation = false
    var locationManager = CLLocationManager()
    var initialLaunch = true
//    var didFailToRegisterPushNotifications = {
//        return NSUserDefaults.standardUserDefaults().boolForKey(kDidFailToRegisterPushNotificationKey)
//        }()
    
    //MARK: - Location Manager setup
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
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
        self.locationManager.startUpdatingLocation()
        
        if CLLocationManager.headingAvailable() {
            self.locationManager.headingFilter = 45
            self.locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    
        if trackingUserLocation{
            
            self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
            var newCamera = self.mapView.camera.copy() as! MKMapCamera
            newCamera.heading = self.mapView.userLocation.location.course
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
        self.title = String.localizedStringWithFormat("איסוף", "collector map title")
        self.publications = FCModel.sharedInstance.publications
        self.newPublicationMessageView.delegate = self
        registerForNSNotifications()
        configureMapView()
        configureTrackButton()
        hideNewDataMessageView()
        addPanRecognizer()
        if CLLocationManager.locationServicesEnabled() {
            self.setupLocationManager()
        }        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tabbarVisibleCenter == CGPointZero {
            self.defineBarsCenterPoints()
            FCModel.sharedInstance.uiReadyForNewData = true
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //uncomment to present enable push notifications message

//        let registeredForRemoteNotifications = UIApplication.sharedApplication().isRegisteredForRemoteNotifications()
//        
//        if !registeredForRemoteNotifications &&
//            NSUserDefaults.standardUserDefaults().boolForKey(kShouldShowFailedToRegisterForPushAlertKey){
//                
//                let alertController = FCAlertsHandler.sharedInstance.alertWithDissmissButton("we can't inform you with new publications", aMessage: "to enable notifications: go to settings -> notifications -> food collector and enable push notifications")
//                self.presentViewController(alertController, animated: true, completion: nil)
//                
//                //comment to show this message every time
//                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShouldShowFailedToRegisterForPushAlertKey)
//        }
//
//        showNewDataMessageView(self.publications[3])
        
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
    
    func hideNewDataMessageView() {
        
        let topConstraintValue = CGRectGetHeight(self.newPublicationMessageView.bounds)
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            
            self.newPublicationMessageViewTopConstraint.constant = -topConstraintValue
            self.view.layoutIfNeeded()
            
            }) { (completion) -> Void in
                
                self.isPresentingNewDataMessageView = false
        }
    }
    
    func showNewDataMessageView(publication:FCPublication) {
        
        if self.isPresentingNewDataMessageView {hideNewDataMessageView()}
        self.newPublicationMessageView.publication = publication
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            
            self.newPublicationMessageViewTopConstraint.constant = self.kNewDataMessageViewTopConstant
            self.view.layoutIfNeeded()
            
        }) { (completion) -> Void in
         
            self.isPresentingNewDataMessageView = true
        }
    }
    
    func defineBarsCenterPoints() {
        
        tabbarDragCenter = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y + self.tabBarController!.tabBar.frame.size.height)
        
        tabbarVisibleCenter = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.AdjustBarsCenterPointsTosize(size)
    }
    
    func AdjustBarsCenterPointsTosize(size: CGSize) {
        
        tabbarVisibleCenter = CGPointMake(size.width/2, size.height - self.tabBarController!.tabBar.frame.size.height / 2)
        tabbarDragCenter = CGPointMake(tabbarVisibleCenter.x, size.height + self.tabBarController!.tabBar.frame.size.height)
    }
    
    func didDragMap(gestureRecognizer: UIPanGestureRecognizer) {
       
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){

            self.panStartingPoint = gestureRecognizer.translationInView(self.mapView)
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
            else {
                //hide activty center
                ShowActivityCenter(self)
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
        annotationView!.image = FCIconFactory.smallIconForPublication(annotation as! FCPublication)
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        let annotation = view.annotation as MKAnnotation
        if annotation .isKindOfClass(MKUserLocation){
            return
        }
        
        let publication = view.annotation as! FCPublication
        self.presentPublicationDetailsTVC(publication)
        self.reloadAnnotations()
        
      //  self.postOnSpotReport(publication)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        //here we setup the initial map region and span
        if initialLaunch {
    
            let span   = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: false)
            initialLaunch = false
        }
        
    }
    
    func presentPublicationDetailsTVC(publication:FCPublication) {
        
        self.publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        self.publicationDetailsTVC?.publication = publication
        self.navigationController!.pushViewController(self.publicationDetailsTVC!, animated: true)
    }
    
    
    // MARK: - ArrivedToSpotView Delegate
   
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
        
        self.isPresentingActivityCenter = !self.isPresentingActivityCenter
        if let delegate = self.delegate {
            self.delegate.collectorVCWillSlide()
        }
    }
}

// MARK: - new data from server logic

extension FCCollectorRootVC {
    
    func didRecieveNewData(notification: NSNotification) {
        
        self.reloadAnnotations()
    }
    
    
    //MARK - new data from push notification.
    //these notifications are posted ny FCModel after handling remote notification events
    
    func didRecieveNewPublication(notification: NSNotification) {
        
        let recivedPublication = FCModel.sharedInstance.publications.last!
        self.reloadAnnotations()
        
        //display new publication view
        self.showNewDataMessageView(recivedPublication)
    }
    
    //MARK: - newDataMessageViewDelegate
    //called when a user tapped show action in newDataMessageView
    func showNewPublicationDetails(publication: FCPublication) {

        self.hideNewDataMessageView()
        self.presentPublicationDetailsTVC(publication)
    }
    
    func dissmissNewPublicationMessageView() {
        self.hideNewDataMessageView()
    }
    
    func didDeletePublication(notification: NSNotification) {

        self.reloadAnnotations()
    }
    
    func didRecievePublicationReport(notification: NSNotification) {
        var (identifier, report ) = FCUserNotificationHandler.sharedInstance.recivedReports.last!
        
        //we need to check if the report belongs to the presented publication to refresh it
        //change this to the presented publication
        var presentedPublication = self.publications[0]
        
        if self.isPresentingNewDataMessageView &&
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
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
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

