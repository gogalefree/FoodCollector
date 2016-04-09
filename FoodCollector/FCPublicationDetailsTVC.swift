//
//  FCPublicationDetailsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import MessageUI
import Social
import CoreData


//let kReportButtonTitle = NSLocalizedString("Report", comment:"Report title for a button")
//let kOptionsButtonTitle = NSLocalizedString("Options", comment:"Report title for a button")
//let kTakeOffAirlertTitle = NSLocalizedString("Confirm Event Ended", comment:"End publication confirmation title for an alert controller")
//let kDeleteAlertTitle = NSLocalizedString("Delete Event?", comment:"Delete confirmation title for an alert controller")


/*
enum PublicationDetailsTVCViewState {

    case Publisher
    case Collector
}


enum PublicationDetailsTVCVReferral {
    
    case MyPublications
    case ActivityCenter
    
}

protocol UserDidDeletePublicationProtocol: NSObjectProtocol {
    func didDeletePublication(publication: Publication, collectionViewIndex: Int)
    func didTakeOffAirPublication(publication: Publication)
}
*/

//class FCPublicationDetailsTVC: UITableViewController, UIPopoverPresentationControllerDelegate, FCPublicationRegistrationsFetcherDelegate, PublicationDetailsOptionsMenuPopUpTVCDelegate {
class FCPublicationDetailsTVC: UITableViewController, UIPopoverPresentationControllerDelegate, FCPublicationRegistrationsFetcherDelegate {
    
    weak var deleteDelgate: UserDidDeletePublicationProtocol?
    
    var publication: Publication?
    var state = PublicationDetailsTVCViewState.Collector
    var referral = PublicationDetailsTVCVReferral.MyPublications
    var publicationIndexNumber = 0
 
    var photoPresentorNavController: FCPhotoPresentorNavigationController!
    var publicationReportsNavController: FCPublicationReportsNavigationController!
    
    weak var actionsHeaderView: PublicationDetsilsCollectorActionsHeaderView?
    
    func setupWithState(initialState: PublicationDetailsTVCViewState, caller: PublicationDetailsTVCVReferral, publication: Publication?, publicationIndexPath:Int = 0) {
        // This function is executed before viewDidLoad()

        self.state = initialState
        self.publication = publication
        self.referral = caller
        self.publicationIndexNumber = publicationIndexPath
        
        switch self.state {
            
        case .Collector:
            GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "publication details", label: "collector state", value: 0)
            
        case .Publisher:
            GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "publication details", label: "publisher state", value: 0)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 65
        fetchPublicationReports()
        fetchPublicationPhoto()
        //fetchPublicationRegistrations()
        registerForNotifications()
        //addTopRightButton(self.state)
        //configAdminIfNeeded()
    }
    
    //MARK: - Table view Headers
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {return 80}
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 1 {
            return nil
        }
        if state == .Collector {
            let header = UIView.loadFromNibNamed("PublicationDetsilsCollectorActionsHeaderView", bundle: nil) as? PublicationDetsilsCollectorActionsHeaderView
            //header?.delegate = self
            header?.publication = self.publication
            self.actionsHeaderView = header
            return header
        }
        else {
            let header = UIView.loadFromNibNamed("PublicationDetsilsPublisherActionsHeaderView", bundle: nil) as? PublicationDetsilsPublisherActionsHeaderView
            header?.delegate = self
            header?.publication = self.publication
            return header
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            //title cell
            if indexPath.row == 0 {return UITableViewAutomaticDimension}
            //image cell
            else if indexPath.row == 1 {return 160}
        case 1:
            //subtitle cell
            if indexPath.row == 0 {return UITableViewAutomaticDimension}
            //dates cell
            else if indexPath.row == 1 {return 97}
            //reports title cell
            else if indexPath.row == 2 {return 60}
        case 2:
            //reports cell
            return 61
        default:
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {return 2}
        else if section == 1 {return 3}
        return PublicationDetailsReportCell.numberOfReportsToPresent(self.publication)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0:
                //Title cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsTitleCellTableViewCell", forIndexPath: indexPath) as! PublicationDetailsTitleCellTableViewCell
                cell.publication = self.publication
                return cell
                
            case 1:
                //Image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsImageCell", forIndexPath: indexPath) as! PublicationDetailsImageCell
                //cell.delegate = self
                cell.publication = self.publication
                return cell
            default:
                 break
            }
            
        case 1:
            switch indexPath.row {
            case 0:
                //Subtitle cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsSubtitleCell", forIndexPath: indexPath) as! PublicationDetailsSubtitleCell
                cell.publication = self.publication
                return cell
            case 1:
                //Dates cell
                let cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationDetailsDatesCell", forIndexPath: indexPath) as! FCPublicationDetailsDatesCell
                cell.publication = self.publication
                return cell
            case 2:
                //Reports title cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsReportsTitleCell", forIndexPath: indexPath) as! PublicationDetailsReportsTitleCell
                return cell
            default:
                break
            }
            
        case 2:
                //Reports cell
                let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsReportCell", forIndexPath: indexPath) as! PublicationDetailsReportCell
                cell.indexPath = indexPath
                cell.publication = self.publication
                return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        //present reports on full screen
        if indexPath.section == 2 {
            
            //self.displayReportsWithFullScreen()
        }
    }
    
    
    func fetchPublicationPhoto() {
        if let publication = self.publication {
            if publication.photoBinaryData == nil && !publication.didTryToDownloadImage!.boolValue {
                
                
                let fetcher = FCPhotoFetcher()
                fetcher.fetchPhotoForPublication(publication, completion: { (image: UIImage?) -> Void in
                    
                    if image != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                   
                            let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                            let imageCell = self.tableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
                            if let cell = imageCell {
                                cell.reloadPublicationImage()
                            }
                        })
                    }
                })
            }
        }
    }
    
    //MARK: - fetch data for publication
    func fetchPublicationReports() {
        
        if let publication = self.publication {
            
            let localContext = FCModel.dataController.createPrivateQueueContext()
            
            localContext.performBlock({ () -> Void in
                
                FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, context: localContext, completion: { (success) -> Void in
                    
                    if success {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
                        })
                    }
                })
            })
        }
    }
    
    func fetchPublicationRegistrations() {
    
        if let publication = self.publication {
            
            let context = FCModel.dataController.managedObjectContext
            context.performBlock({ () -> Void in
                
                let fetcher = CDPublicationRegistrationFetcher(publication: publication, context: context)
                fetcher.delegate = self
                fetcher.fetchRegistrationsForPublication(false)
            })
        }
    }
    
    func didFinishFetchingPublicationRegistrations() {
   
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PublicationDetailsImageCell
            if let imageCell = cell {
                imageCell.reloadRegisteredUserIconCounter()
            }
        }
    }
    
    //MARK: - Remote Notification Handling
    func didDeletePublication(notification: NSNotification) {
        
        let deleted = FCModel.sharedInstance.userDeletedPublication
        
        
            if let publication = self.publication {
                
                if deleted?.uniqueId == publication.uniqueId && deleted?.version == publication.version {
                    
                    let alert = UIAlertController(title: publication.title, message: kDeleteAlertTitle, preferredStyle: .Alert)
                    let action = UIAlertAction(title: kOKButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        
    }
    
    func didRecievePublicationRegistration(notification: NSNotification) {
        
        let info = notification.userInfo as? [String : AnyObject]
        
        if let userInfo = info {
            
            let publication = userInfo["publication"] as! Publication
            if let presentedPublication = self.publication {
                
                if  presentedPublication.uniqueId == publication.uniqueId &&
                    presentedPublication.version == publication.version {
                        
                        let imageCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PublicationDetailsImageCell
                        if let cell = imageCell {
                         
                            cell.reloadRegisteredUserIconCounter()
                        }
                }
            }
        }
    }
    
    
    //MARK: - NSNotifications
    func registerForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
}

////MARK: - Collector Actions Header delegate
//
//extension FCPublicationDetailsTVC: PublicationDetsilsCollectorActionsHeaderDelegate {
//    
//    
//    func didRegisterForPublication(publication: Publication) {
//        // If the user is logged in: register him to this pickup.
//        // If the user is NOT logged in: start login process.
//        
//        if User.sharedInstance.userIsLoggedIn {
//            registerUserForPublication()
//        }
//        else {
//            showNotLoggedInAlert()
//        }
//    }
//    
//    func didUnRegisterForPublication(publication: Publication) {
//        
//        publication.didRegisterForCurrentPublication = false
//        FCModel.sharedInstance.removeRegistrationFor(publication)
//        self.updateRegisteredUserIconCounter()
//        animateRegistrationButton() 
//    }
//    
//    func didRequestNavigationForPublication(publication: Publication) {
//        
//        
//        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"waze://")!)){
//            let title = NSLocalizedString("Navigate with:", comment:"an action sheet title meening chose app to navigate with")
//            let actionSheet = FCAlertsHandler.sharedInstance.navigationActionSheet(title, publication: publication)
//            self.presentViewController(actionSheet, animated: true, completion: nil)
//        }
//        else {
//            //navigateWithWaze
//            FCNavigationHandler.sharedInstance.wazeNavigation(publication)
//        }
//    }
//    
//    func didRequestSmsForPublication(publication: Publication) {
//        
//        if let phoneNumber = self.publication?.contactInfo {
//            
//            if MFMessageComposeViewController.canSendText() {
//                
//                let messageVC = MFMessageComposeViewController()
//                messageVC.body = String.localizedStringWithFormat(NSLocalizedString("I want to pickup %@", comment:"SMS message body: I want to pickup 'Publication name'"), publication.title!)
//                messageVC.recipients = [phoneNumber]
//                //messageVC.messageComposeDelegate = self
//                self.navigationController?.presentViewController(messageVC, animated: true, completion: nil)
//                
//            }
//        }
//    }
//    
//    func didRequestPhoneCallForPublication(publication: Publication) {
//        
//        if let phoneNumber = self.publication?.contactInfo {
//            
//            let telUrl = NSURL(string: "tel://\(phoneNumber)")!
//
//            if UIApplication.sharedApplication().canOpenURL(telUrl){
//                
//                UIApplication.sharedApplication().openURL(telUrl)
//            }
//        }
//    }
//    
//    private func registerUserForPublication() {
//        publication!.didRegisterForCurrentPublication = true
//        FCModel.sharedInstance.addRegisterationFor(publication!)
//        self.updateRegisteredUserIconCounter()
//        self.animateRegistrationButton()
//    }
//
//    private func animateRegistrationButton() {
//        actionsHeaderView?.animateButton((actionsHeaderView?.registerButton)!)
//        actionsHeaderView?.configureRegisterButton()
//    }
//    
//    private func updateRegisteredUserIconCounter() {
//        
//        let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
//        let imageCell = self.tableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
//        if let cell = imageCell {
//            cell.reloadRegisteredUserIconCounter()
//        }
//    }
//    
//    func showNotLoggedInAlert() {
//        let alertController = UIAlertController(title: kAlertLoginTitle, message: kAlertLoginMessage, preferredStyle: UIAlertControllerStyle.Alert)
//        
//        // Add buttons
//        alertController.addAction(UIAlertAction(title: kAlertLoginButtonTitle, style: UIAlertActionStyle.Default,handler: { (action) -> Void in
//            self.startLoginprocess()
//        }))
//        alertController.addAction(UIAlertAction(title: kCancelButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
//    
//    func startLoginprocess() {
//        print("startLoginprocess")
//        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
//        let identityProviderLogingViewNavVC = loginStoryboard.instantiateViewControllerWithIdentifier("IdentityProviderLoginNavVC") as! UINavigationController
//        
//        self.presentViewController(identityProviderLogingViewNavVC, animated: true, completion: nil)
//    }
//    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }
//    
//    
//}

//MARK: - Publisher Actions Header delegate

extension FCPublicationDetailsTVC: PublicationDetsilsPublisherActionsHeaderDelegate {
    
    
    func didRequestPostToFacebookForPublication() {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let facebookPostController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookPostController.setInitialText(publication?.title)
            if let data = publication?.photoBinaryData {
                facebookPostController.addImage(UIImage(data: data))

            }
            facebookPostController.addURL(NSURL(string: "https://www.facebook.com/foodonet"))
            self.presentViewController(facebookPostController, animated:true, completion:nil)
        }
    }
    
    func didRequestPostToTwitterForPublication() {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let twiiterPostController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            let hashTagString = "#FooDoNet: "
            let title = publication?.title
            twiiterPostController.setInitialText(hashTagString + title!)
            
            if let data = publication?.photoBinaryData {
                twiiterPostController.addImage(UIImage(data: data))
                
            }
            twiiterPostController.addURL(NSURL(string: "https://www.facebook.com/foodonet"))
            self.presentViewController(twiiterPostController, animated:true, completion:nil)
        }
    }
    
    func publisherDidRequestSmsCollectors() {
        
        let registrations = publication?.registrations
        
        if registrations == nil || registrations?.count == 0 {
            let title = NSLocalizedString("No one is registered for this pickup", comment:"")
            presentNoCollectorsAlert(title)
            return
        }
        
        
        let validator = Validator()
        let array = Array(registrations!) as! [PublicationRegistration]
        let trueNumbers = array.filter { (registration) in validator.getValidPhoneNumber(registration.collectorContactInfo!) != nil }
        if trueNumbers.count == 0 {
            
            let title = NSLocalizedString("There are no legit phone numbers", comment:"")
            presentNoCollectorsAlert(title)
            return
        }
        
        
        //present ContactCollectorPicker
        let contactCollectorPickerNavVC = storyboard?.instantiateViewControllerWithIdentifier("ContactCollectorsNavController") as! UINavigationController
        contactCollectorPickerNavVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        contactCollectorPickerNavVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        let contactCollectorPicker = contactCollectorPickerNavVC.viewControllers[0] as! ContactCollectorsPickerTVC
        contactCollectorPicker.publication = self.publication
        self.navigationController?.presentViewController(contactCollectorPickerNavVC, animated: true, completion: nil)
    }
    
    func publisherDidRequestPhoneCall() {
    
        let registrations = publication?.registrations
        
        if registrations == nil || registrations?.count == 0 {
        
            let title = NSLocalizedString("No one is registered for this pickup", comment:"")
            presentNoCollectorsAlert(title)
            return
        }
        
        let registrationsArray = Array(publication!.registrations!) as! [PublicationRegistration]
        //present ContactCollectorPhonePicker
        let contactCollectorPhonePickerNavVC = storyboard?.instantiateViewControllerWithIdentifier("ContactCollectorPhonePickerNavVC") as! UINavigationController
        contactCollectorPhonePickerNavVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        contactCollectorPhonePickerNavVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        let contactCollectorPhonePicker = contactCollectorPhonePickerNavVC.viewControllers[0] as! ContactCollectorPhonePickerVC
        contactCollectorPhonePicker.registrations = registrationsArray
        self.navigationController?.presentViewController(contactCollectorPhonePickerNavVC, animated: true, completion: nil)
    }
    
    func presentNoCollectorsAlert(title: String) {
        
        let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(title, aMessage: "")
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
}


//MARK: - Image cell delegate

//extension FCPublicationDetailsTVC : PublicationDetailsImageCellDelegate {
//    
//    
//    func didRequestFullScreenImage() {
//        self.presentPhotoPresentor()
//    }
//    
//    func presentPhotoPresentor() {
//        
//        //add if to check whether there's a photo or default
//        if self.publication?.photoBinaryData == nil {return}
//        
//        self.photoPresentorNavController = self.storyboard?.instantiateViewControllerWithIdentifier("photoPresentorNavController") as! FCPhotoPresentorNavigationController
//
//        self.photoPresentorNavController.transitioningDelegate = self
//        self.photoPresentorNavController.modalPresentationStyle = .Custom
//        
//        let photoPresentorVC = self.photoPresentorNavController.viewControllers[0] as! PublicationPhotoPresentorVC
//        photoPresentorVC.publication = self.publication
//        
//        self.navigationController?.presentViewController(
//            self.photoPresentorNavController, animated: true, completion:nil)
//    }
//}

//extension FCPublicationDetailsTVC: UIViewControllerTransitioningDelegate {
//    
//    //MARK: - Transition Delegate
//    
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
//       
//        var pcontrol: UIPresentationController!
//        
//        if presented is FCPhotoPresentorNavigationController {
//            
//            pcontrol = PublicationPhotoPresentorPresentationController(
//            presentedViewController: self.photoPresentorNavController,
//            presentingViewController: self.navigationController!)
//        }
//        
//        else if presented is FCPublicationReportsNavigationController{
//            
//            pcontrol = FCPublicationReportsPresentationController( presentedViewController: self.publicationReportsNavController,
//                presentingViewController: self.navigationController!)
//        }
//        
//        return  pcontrol
//    }
//    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        //starting frame for transition
//        if presented is FCPhotoPresentorNavigationController {
//
//            let photoPresentorVCAnimator = PublicationPhotoPresentorAnimator()
//
//            var originFrame = CGRectZero
//            //TODO: set initial photo frame
//            let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
//            let imageCell = self.tableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
//            if let cell = imageCell {
//                originFrame = self.view.convertRect(cell.publicationImageView.frame, fromView: cell)
//            }
//            
//            photoPresentorVCAnimator.originFrame = originFrame
//            return photoPresentorVCAnimator
//        }
//        
//        else if presented is FCPublicationReportsNavigationController{
//            
//            let publicationReportsAnimator = FCPublicationReportsVCAnimator()
//            var startingFrame = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
//    //        startingFrame.origin.y += kTableViewHeaderHeight
//            startingFrame.size.width = startingFrame.size.width / 2
//    
//            publicationReportsAnimator.originFrame = startingFrame
//            return publicationReportsAnimator
//            
//        }
//        
//        return nil
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if dismissed is FCPhotoPresentorNavigationController {
//            return PublicationPhotoPresentorDissmissAnimator()
//        }
//        else if dismissed == self.publicationReportsNavController {
//            
//            let animator = FCPublicationReportsDismissAnimator()
//            
//            let destinationFrame =
//            self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
//            
//            animator.destinationRect = destinationFrame
//            
//            return animator
//        }
//        
//        return nil
//    }
//}

//extension FCPublicationDetailsTVC {
//    //MARK: - reports cell full screen
//    
//
//    func displayReportsWithFullScreen() {
//        
//        let reports = publication?.reports
//        
//        if reports == nil || reports?.count == 0 {return}
//
//       
//            let publicationReportsNavController = self.storyboard?.instantiateViewControllerWithIdentifier("publicationReportsNavController") as! FCPublicationReportsNavigationController
//            self.publicationReportsNavController = publicationReportsNavController
//            
//            publicationReportsNavController.transitioningDelegate = self
//            publicationReportsNavController.modalPresentationStyle = .Custom
//            
//            let publicationReportsTVC = publicationReportsNavController.viewControllers[0] as! FCPublicationReportsTVC
//            
//            publicationReportsTVC.publication = self.publication
//            
//            self.navigationController?.presentViewController(publicationReportsNavController, animated: true, completion: { () -> Void in})
//        
//        }
//
//}
//
////MARK: - SMS Message Composer
//
//extension FCPublicationDetailsTVC : MFMessageComposeViewControllerDelegate {
//    
//    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
//        
//        switch (result.rawValue) {
//        
//        case MessageComposeResultCancelled.rawValue:
//            print("Message was cancelled")
//            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
//       
//        case MessageComposeResultFailed.rawValue:
//            
//            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
//
//            
//            let alert = UIAlertController(title: kSendSMSfailedAlertTitle, message: kSendSMSTryAgainAlertMessage, preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default , handler: { (action) -> Void in
//                self.didRequestSmsForPublication(self.publication!)
//            }))
//            alert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Cancel, handler: { (action) -> Void in
//                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
//            }))
//            
//            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
//            
//        case MessageComposeResultSent.rawValue:
//            print("Message was sent")
//            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
//        default:
//            break;
//        }
//    }
//}

////MARK: - Report Button and delegate
//
//extension FCPublicationDetailsTVC : FCOnSpotPublicationReportDelegate {
//    
//    func addTopRightButton(buttonType: PublicationDetailsTVCViewState) {
//        var buttonValus = (kReportButtonTitle, "presentReportVC")
//        
//        if buttonType == PublicationDetailsTVCViewState.Publisher {
//            buttonValus = (kOptionsButtonTitle, "presentOptionsMenuVC")
//        }
//            
//        createTopRightButton(label: buttonValus.0, andAction: buttonValus.1)
//    }
//    
//    func createTopRightButton(label label:String, andAction actionName: String) {
//        let actionSelector = Selector(stringLiteral: actionName)
//        let topRightButton = UIBarButtonItem(
//                title: label,
//                style: UIBarButtonItemStyle.Done,
//                target: self,
//                action: actionSelector)
//        self.navigationItem.setRightBarButtonItem(topRightButton, animated: false)
//    }
//    
//    
//    func presentReportVC() {
//        
//        if User.sharedInstance.userIsLoggedIn {
//            let arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
//            
//            arrivedToSpotReportVC.publication = self.publication
//            arrivedToSpotReportVC.delegate = self
//            
//            let navController = UINavigationController(rootViewController: arrivedToSpotReportVC) as UINavigationController
//            
//            self.navigationController?.presentViewController(navController, animated: true, completion: nil)
//        }
//        else {
//            showNotLoggedInAlert()
//        }
//    }
//    
//    //MARK: - Reports delegate
//
//    func dismiss(report: PublicationReport?) {
//
//        if self.presentedViewController != nil {
//            self.dismissViewControllerAnimated(true, completion: nil)
//            self.tableView.reloadData()
//        }
//    }
//    
//    //MARK: - Options menue
//    func presentOptionsMenuVC(){
//        
//        if User.sharedInstance.userIsLoggedIn {
//            let optionsMenuPopUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("publisherOptionsMenuVC") as! PublicationOptionsMenuTVC
//            optionsMenuPopUpVC.delegate = self
//            optionsMenuPopUpVC.publication = publication
//            
//            optionsMenuPopUpVC.popoverPresentationController?.delegate = self
//            optionsMenuPopUpVC.modalPresentationStyle = UIModalPresentationStyle.Popover
//            if publication!.isOnAir! == true {
//                // 44 is the row height of each cell in the options menu table
//                optionsMenuPopUpVC.preferredContentSize = CGSizeMake(150, (44*3-1))
//            }
//            else {
//                optionsMenuPopUpVC.preferredContentSize = CGSizeMake(150, (44*2-1))
//            }
//            
//            //get the popup presentation controller. it is a property on every
//            //View Controller subclass. there you set the arrows direction etc. take a look at
//            //it's properties, it's very flexible.
//            
//            let popUpPC = optionsMenuPopUpVC.popoverPresentationController
//            popUpPC?.delegate = self
//            popUpPC?.permittedArrowDirections = UIPopoverArrowDirection.Up
//            popUpPC?.barButtonItem = self.navigationItem.rightBarButtonItem
//            
//            self.presentViewController(optionsMenuPopUpVC, animated: true, completion: nil)
//        
//        }
//        else {
//            showNotLoggedInAlert()
//        }
//    }
//    
//    func adaptivePresentationStyleForPresentationController(
//        controller: UIPresentationController) -> UIModalPresentationStyle {
//            return .None
//    }
//    
//    
//}

////MARK: - Admin for beta bundle
//
//extension FCPublicationDetailsTVC {
//    
//    func configAdminIfNeeded() {
//        
//        var infoPlist: NSDictionary?
//        
//        if let path = NSBundle.mainBundle().pathForResource("Info", ofType:"plist") {
//            
//            infoPlist = NSDictionary(contentsOfFile: path)
//        }
//        
//        if let infoPlist = infoPlist {
//            
//            let bundleName = infoPlist["CFBundleName"] as! String
//            let bundleID = infoPlist["CFBundleIdentifier"] as! String
//            print("BUNDLE ID: \(bundleID)")
//            if bundleName.hasPrefix("beta") {
//             
//                print("Beta Version. adding deleteButton")
//                addDeletButton()
//            }
//        }
//        else {
//            print("Config Admin **************: NOT FOUND")
//            
//        }
//    }
//    
//    func addDeletButton() {
//        
//        let deleteButton = UIBarButtonItem(title: "delete", style: UIBarButtonItemStyle.Plain, target: self, action: "deletePublication")
//        self.navigationItem.setRightBarButtonItem(deleteButton, animated: false)
//    }
//    
//    func deletePublication() {
//        print("deleting publication")
//        
////        let identifier = PublicationIdentifier(uniqueId: self.publication!.uniqueId!.integerValue , version: self.publication!.version!.integerValue)
////        
////        FCModel.sharedInstance.foodCollectorWebServer.deletePublication(identifier, completion: { (success) -> () in
////            
////            if success {
////                self.dismissViewControllerAnimated(true, completion: nil)
////            }
////            
////            else {
////                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("Error deleting", aMessage: "publication id: \(identifier.uniqueId) version: \(identifier.version) ")
////                self.presentViewController(alert, animated: true, completion: nil)
////            }
////        })
//    }
//}
//
////MARK: - PublicationDetailsOptionsMenuPopUpTVCDelegate Protocol
//
//extension FCPublicationDetailsTVC {
//    
//    func didSelectEditPublicationAction(){
//     //   dismiss()
//
//        let publicationEditorTVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublicationEditorTVC") as? PublicationEditorTVC
//        publicationEditorTVC?.setupWithState(.EditPublication, publication: publication!)
//        
//        
//        let nav = UINavigationController(rootViewController: publicationEditorTVC!)
//        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
//
//    }
//    
//    func didSelectTakOffAirPublicationAction() {
//        
//        let takeOffAirAlert = UIAlertController(title: kTakeOffAirlertTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//        
//        takeOffAirAlert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default, handler: { (action: UIAlertAction!) in
//            self.deleteDelgate?.didTakeOffAirPublication(self.publication!)
//        }))
//        
//        takeOffAirAlert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
//        }))
//        
//        presentViewController(takeOffAirAlert, animated: true, completion: nil)
//        
//    }
//    
//    func didSelectDeletePublicationAction() {
//        
//        let deleteAlert = UIAlertController(title: kDeleteAlertTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//        
//        deleteAlert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
//            
//            //delete from model
//            deleteAlert.dismissViewControllerAnimated(true, completion: nil)
//            FCModel.sharedInstance.deletePublication(self.publication!, deleteFromServer: true)
//            self.deleteDelgate?.didDeletePublication(self.publication!, collectionViewIndex: self.publicationIndexNumber)
//        }))
//        
//        deleteAlert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Default, handler: nil))
//        self.presentViewController(deleteAlert, animated: true, completion: nil)
//    }
//    
//    func reload() {
//        print("reload")
//        self.tableView.reloadData()
//    }
//}




