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
    @IBOutlet weak var newPublicationMessageViewTopConstraint: NSLayoutConstraint!  //consider Deprecation
    @IBOutlet weak var newPublicationMessageView: FCCollectorNewDataMessageView!    //consider Deprecation
    
    weak var delegate: CollectorVCSlideDelegate!

    var publications = [Publication]()
    var annotations = [FDAnnotation]()
    var isPresentingNewDataMessageView = false
    var panStartingPoint: CGPoint!
    let kNewDataMessageViewTopConstant: CGFloat = 13
    var publicationDetailsTVC: FCPublicationDetailsTVC?
    var isPresentingActivityCenter = false
  //  var tabbarVisibleCenter = CGPointZero
  //  var tabbarDragCenter = CGPointZero
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
  //      self.newPublicationMessageView.delegate = self
        registerForNSNotifications()
        configureMapView()
        configureTrackButton()
 //       hideNewDataMessageView()
        addPanRecognizer()
        if CLLocationManager.locationServicesEnabled() {
            self.setupLocationManager()
        }
        
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
    
//    func showNewPublicationMessageViewIfNeeded() {
//        
//        if let data =  NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTypeNewPublication) as? [NSObject : AnyObject] {
//            
//            let id = data[kPublicationUniqueIdKey] as! Int
//            let version = data[kPublicationVersionKey] as! Int
//            let identifier = PublicationIdentifier(uniqueId: id, version: version)
//            FCModel.sharedInstance.foodCollectorWebServer.fetchPublicationWithIdentifier(identifier, completion: { (publication) -> Void in
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    
//                    self.showNewDataMessageView(publication)
//                })
//                
//                NSUserDefaults.standardUserDefaults().removeObjectForKey(kRemoteNotificationTypeNewPublication)
//                
//            })
//        }
//    }
    
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
    
//    func hideNewDataMessageView() {
//        
//        let topConstraintValue = CGRectGetHeight(self.newPublicationMessageView.bounds)
//        
//        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
//            
//            self.newPublicationMessageViewTopConstraint.constant = -topConstraintValue
//            self.view.layoutIfNeeded()
//            
//            }) { (completion) -> Void in
//                
//                self.isPresentingNewDataMessageView = false
//        }
//    }
    
//    func showNewDataMessageView(publication:FCPublication) {
//        
//        if self.isPresentingNewDataMessageView {hideNewDataMessageView()}
//        self.newPublicationMessageView.publication = publication
//        
//        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
//            
//            self.newPublicationMessageViewTopConstraint.constant = self.kNewDataMessageViewTopConstant
//            self.view.layoutIfNeeded()
//            
//        }) { (completion) -> Void in
//         
//            self.isPresentingNewDataMessageView = true
//            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShouldShowNewPublicationFromPushNotification)
//        }
//    }
    
//    func defineBarsCenterPoints() {
//        
//        tabbarDragCenter = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y + self.tabBarController!.tabBar.frame.size.height)
//        
//        tabbarVisibleCenter = CGPointMake(self.tabBarController!.tabBar.center.x, self.tabBarController!.tabBar.center.y)
//    }
//    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        self.AdjustBarsCenterPointsTosize(size)
//    }
//    
//    func AdjustBarsCenterPointsTosize(size: CGSize) {
//        
//        tabbarVisibleCenter = CGPointMake(size.width/2, size.height - self.tabBarController!.tabBar.frame.size.height / 2)
//        tabbarDragCenter = CGPointMake(tabbarVisibleCenter.x, size.height + self.tabBarController!.tabBar.frame.size.height)
//    }
    
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
    
//    func hideTabbar() {
//        
//        self.tabBarController!.tabBar.animateCenterWithSpring(0.4, center: self.tabbarDragCenter)
//    }
//    
//    func showTabbar() {
//        
//        self.tabBarController!.tabBar.animateCenterWithSpring(0.4, center: self.tabbarVisibleCenter)
//    }
    
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
        
        self.publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
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
    
    // MARK: - ArrivedToSpotView Delegate
   
//    func postOnSpotReport(publication: FCPublication) {
//
//        var userInfo = [NSObject : AnyObject]()
//        userInfo[kPublicationUniqueIdKey] = publication.uniqueId
//        userInfo[kPublicationVersionKey] = publication.version
//        NSNotificationCenter.defaultCenter().postNotificationName(kDidArriveOnSpotNotification, object: self, userInfo: userInfo)
//    }
//    
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
    
    
    //MARK - new data from push notification.
    //these notifications are posted ny FCModel after handling remote notification events
    
//    func didRecieveNewPublication(notification: NSNotification) {
//        
//        let recivedPublication = FCModel.sharedInstance.publications.last!
//        self.reloadAnnotations()
//        
//        //display new publication view
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.showNewDataMessageView(recivedPublication)
//        })
//    }
    
    //MARK: - newDataMessageViewDelegate
    //called when a user tapped show action in newDataMessageView
    func showNewPublicationDetails(publication: Publication) {

       // self.hideNewDataMessageView()
        self.presentPublicationDetailsTVC(publication)
    }
    
//    func dissmissNewPublicationMessageView() {
//        self.hideNewDataMessageView()
//    }
    
    func didDeletePublication(notification: NSNotification) {

        self.reloadAnnotations()
    }
    
//    func didRecievePublicationReport(notification: NSNotification) {
//        let (identifier, _) = FCUserNotificationHandler.sharedInstance.recivedReports.last!
//        
//        //we need to check if the report belongs to the presented publication to refresh it
//        //change this to the presented publication
//        let presentedPublication = self.publications[0]
//        
//        if self.isPresentingNewDataMessageView &&
//            presentedPublication.uniqueId == identifier.uniqueId &&
//            presentedPublication.version == identifier.version {
//                
//                //self.publicationDetailsView.reloadReports
//        }
//    }
//    
    
//    func publicationWithIdentifier(identifier: PublicationIdentifier) -> FCPublication? {
//        var requestedPublication: FCPublication?
//        for publication in self.publications {
//            if publication.uniqueId == identifier.uniqueId &&
//                publication.version == identifier.version{
//                    requestedPublication = publication
//            }
//        }
//        return requestedPublication
//    }
    
    func reloadAnnotations() {
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mapView.removeAnnotations(self.annotations)
            self.publications = FCModel.sharedInstance.publications
            let annotations = self.makeAnnotations()
            self.mapView.addAnnotations(annotations)
        })
    }
    
//    func appWillEnterForeground() {
//        self.showNewPublicationMessageViewIfNeeded()
//    }
    
    func registerForNSNotifications() {
        
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadAnnotations", name: "didFetchNewPublicationReportNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData:", name: kRecievedNewDataNotification, object: nil)
        
      //  NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewPublication:", name: kRecievedNewPublicationNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
                
    //    NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)

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

