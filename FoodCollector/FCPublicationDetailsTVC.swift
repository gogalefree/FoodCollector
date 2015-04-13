//
//  FCPublicationDetailsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationDetailsTVC: UITableViewController, UIScrollViewDelegate {
    
    var publication: FCPublication?
    
    private let kTableViewHeaderHeight: CGFloat = 300.0
    var headerView: FCPublicationDetailsTVHeaderView!

    var photoPresentorNavController: FCPhotoPresentorNavigationController!
    var publicationReportsNavController: FCPublicationReportsNavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 140
        configureHeaderView()
        fetchPublicationReports()
        fetchPublicationPhoto()
        registerForNotifications()
        
        self.title = publication?.title
        
    }
    
    func configureHeaderView() {
        
        headerView = self.tableView.tableHeaderView as! FCPublicationDetailsTVHeaderView
        self.tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        headerView.publication = self.publication
        addTapGestureToHeaderView()
        
        self.tableView.contentInset = UIEdgeInsets(top: kTableViewHeaderHeight, left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset = CGPointMake(0, -kTableViewHeaderHeight)
        updateHeaderView()

    }
    
    func updateHeaderView() {
        
        var headerRect = CGRect(x: 0, y: -kTableViewHeaderHeight, width: self.tableView.bounds.width, height: kTableViewHeaderHeight)
        if self.tableView.contentOffset.y < -kTableViewHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        self.headerView.frame = headerRect
        
        self.headerView.updateCutAway(headerRect)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return FCPublicationDetailsTVReportsCell.heightForPublication(self.publication)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //change to 4 if we want the photo cell down
        return 3
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationsDetailsTVTitleCell", forIndexPath: indexPath)as! FCPublicationsDetailsTVTitleCell
            cell.delegate = self
            cell.publication = self.publication
            return cell
        }
        else if indexPath.row == 1 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("reportsCell", forIndexPath: indexPath) as! FCPublicationDetailsTVReportsCell
            cell.delegate = self
            cell.publication = self.publication
            return cell
            
        }
        else if indexPath.row == 2 {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("FCPublicationDetailsDatesCell", forIndexPath: indexPath) as! FCPublicationDetailsDatesCell
            cell.publication = self.publication
            return cell
        }
        else if indexPath.row == 3 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationDetailsPhotoCell", forIndexPath: indexPath) as! FCPublicationDetailsPhotoCell
            cell.publication = self.publication
            return cell
        }
        else {
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "stamCell") as UITableViewCell
            return cell
            
        }
    }
    
    func fetchPublicationPhoto() {
        if let publication = self.publication {
            if publication.photoData.photo == nil && !publication.photoData.didTryToDonwloadImage {
                
                
                let fetcher = FCPhotoFetcher()
                fetcher.fetchPhotoForPublication(publication, completion: { (image: UIImage?) -> Void in
                    if publication.photoData.photo != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.headerView.updatePhoto()
                        })
                    }
                })
            }
        }
    }
    
    //MARK: - fetch data for publication
    func fetchPublicationReports() {
        
        if let publication = self.publication {
            FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, completion: { (success: Bool, reports: [FCOnSpotPublicationReport]?) -> () in
                
                if success {
                    if let incomingReports = reports {
                        publication.reportsForPublication = incomingReports
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let reportsCellIp = NSIndexPath(forRow: 1, inSection: 0)
                            self.tableView.reloadRowsAtIndexPaths([reportsCellIp], withRowAnimation: .Automatic)
                        })
                    }
                }
            })
        }
    }
    
    func didDeletePublication(notification: NSNotification) {
        
        let publicationIdentifier = FCUserNotificationHandler.sharedInstance.recivedtoDelete.last
        
        if let identifier = publicationIdentifier {
            
            if let publication = self.publication {
                
                if identifier.uniqueId == publication.uniqueId && identifier.version == publication.version{
                    
                    let alert = UIAlertController(title: publication.title, message: kpublicationDeletedAlertMessage, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "okay", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
}

extension FCPublicationDetailsTVC: FCPublicationDetailsTitleCellDelegate {
    
    //MARK: - Title cell delegate
    
    func didRegisterForPublication(publication: FCPublication) {
        
        publication.didRegisterForCurrentPublication = true
        publication.countOfRegisteredUsers += 1
        
        FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(publication, message: FCRegistrationForPublication.RegistrationMessage.register)
        
        FCModel.sharedInstance.savePublications()
        
        //show alert controller
        if publication.typeOfCollecting == FCTypeOfCollecting.ContactPublisher {
            
            let title = String.localizedStringWithFormat("Please Contact the Publisher", "an alert title requesting to contact the publisher")
            let subtitle = String.localizedStringWithFormat("Call: \(publication.contactInfo!)", "the word call before presenting the phone number")
            let alert = FCAlertsHandler.sharedInstance.alertWithCallDissmissButton(title, aMessage: subtitle, phoneNumber: publication.contactInfo!)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func didUnRegisterForPublication(publication: FCPublication) {
        
        publication.didRegisterForCurrentPublication = false
        publication.countOfRegisteredUsers -= 1
        FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(publication, message: FCRegistrationForPublication.RegistrationMessage.unRegister)
        
        FCModel.sharedInstance.savePublications()
    }
    
    func didRequestNavigationForPublication(publication: FCPublication) {
        
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"waze://")!)){
            let title = String.localizedStringWithFormat("Navigate With:", "an action sheet title meening chose app to navigate with")
            let actionSheet = FCAlertsHandler.sharedInstance.navigationActionSheet(title, publication: publication)
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
        else {
            //navigateWithWaze
            FCNavigationHandler.sharedInstance.wazeNavigation(publication)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
}

extension FCPublicationDetailsTVC : UIGestureRecognizerDelegate {
    
    //MARK: - Header View gesture recognizer
    
    func addTapGestureToHeaderView() {
        
        let recognizer = UITapGestureRecognizer(target: self, action: "headerTapped")
        recognizer.delegate = self
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.headerView.addGestureRecognizer(recognizer)
    }
    
    func headerTapped () {
        
        //add if to check whether there's a photo or default
        if self.publication?.photoData.photo == nil {return}
        
        self.photoPresentorNavController = self.storyboard?.instantiateViewControllerWithIdentifier("photoPresentorNavController") as! FCPhotoPresentorNavigationController

        self.photoPresentorNavController.transitioningDelegate = self
        self.photoPresentorNavController.modalPresentationStyle = .Custom
        
        let photoPresentorVC = self.photoPresentorNavController.viewControllers[0] as! PublicationPhotoPresentorVC
        photoPresentorVC.publication = self.publication
        
        self.navigationController?.presentViewController(
            self.photoPresentorNavController, animated: true, completion:nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension FCPublicationDetailsTVC: UIViewControllerTransitioningDelegate {
    
    //MARK: - Transition Delegate
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
       
        var pcontrol: UIPresentationController!
        
        if presented is FCPhotoPresentorNavigationController {
            
            pcontrol = PublicationPhotoPresentorPresentationController(
            presentedViewController: self.photoPresentorNavController,
            presentingViewController: self.navigationController!)
        }
        
        else if presented is FCPublicationReportsNavigationController{
            
            pcontrol = FCPublicationReportsPresentationController( presentedViewController: self.publicationReportsNavController,
                presentingViewController: self.navigationController)
        }
        
        return  pcontrol
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        //starting frame for transition
        if presented is FCPhotoPresentorNavigationController {

            var photoPresentorVCAnimator = PublicationPhotoPresentorAnimator()
          //  self.publicationPhotoPresentorAnimator = photoPresentorVCAnimator
            photoPresentorVCAnimator.originFrame = self.headerView.bounds
            return photoPresentorVCAnimator
        }
        
        else if presented is FCPublicationReportsNavigationController{
            
            var publicationReportsAnimator = FCPublicationReportsVCAnimator()
            var startingFrame = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            startingFrame.origin.y += kTableViewHeaderHeight
            startingFrame.size.width = startingFrame.size.width / 2
    
            publicationReportsAnimator.originFrame = startingFrame
            return publicationReportsAnimator
            
        }
        
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed is FCPhotoPresentorNavigationController {
            return PublicationPhotoPresentorDissmissAnimator()
        }
        else if dismissed == self.publicationReportsNavController {
            
            let animator = FCPublicationReportsDismissAnimator()
            
            var destinationFrame =
            self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            
            destinationFrame.origin.y += kTableViewHeaderHeight
            animator.destinationRect = destinationFrame
            
            return animator
        }
        
        return nil
    }
}

extension FCPublicationDetailsTVC: PublicationDetailsReprtsCellDelegate {
    //MARK: - reports cell Delegate
    //show full reports list on full screen
    

    func displayReportsWithFullScreen() {

        if self.publication!.reportsForPublication.count != 0 {
            let publicationReportsNavController = self.storyboard?.instantiateViewControllerWithIdentifier("publicationReportsNavController") as! FCPublicationReportsNavigationController
            self.publicationReportsNavController = publicationReportsNavController
            
            publicationReportsNavController.transitioningDelegate = self
            publicationReportsNavController.modalPresentationStyle = .Custom
            
            let publicationReportsTVC = publicationReportsNavController.viewControllers[0] as! FCPublicationReportsTVC
            
            publicationReportsTVC.publication = self.publication
            
            self.navigationController?.presentViewController(publicationReportsNavController, animated: true, completion: { () -> Void in})
        }
    }

}