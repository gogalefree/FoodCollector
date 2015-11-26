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


let kReportButtonTitle = String.localizedStringWithFormat("דווח", "Report title for a button")
let kOptionsButtonTitle = String.localizedStringWithFormat("אפשרויות", "Report title for a button")
let kTakeOffAirlertTitle = String.localizedStringWithFormat("אישור הפסקת פרסום אירוע", "Delete confirmation title for an alert controller")
let kTakeOffAirAlertMessage = String.localizedStringWithFormat("בחרתם להפסיק את פרסום האירוע. אתם בטוחים?", "Delete confirmation message for an alert controller")
let kDeleteAlertTitle = String.localizedStringWithFormat("אישור מחיקת אירוע", "Delete confirmation title for an alert controller")
let kDeleteAlertMessage = String.localizedStringWithFormat("בחרתם למחוק את האירוע. זה סופי?", "Delete confirmation message for an alert controller")
let kAlertOKButtonTitle = String.localizedStringWithFormat("כן", "OK title for an alert button")
let kAlertCancelButtonTitle = String.localizedStringWithFormat("לא", "Cancel title for an alert button")



enum PublicationDetailsTVCViewState {

    case Publisher
    case Collector
}

enum PublicationDetailsTVCVReferral {
    
    case MyPublications
    case ActivityCenter
    
}

protocol UserDidDeletePublicationProtocol: NSObjectProtocol {
    func didDeletePublication(publication: FCPublication, collectionViewIndex: Int)
    func didTakeOffAirPublication(publication: FCPublication)
}

class FCPublicationDetailsTVC: UITableViewController, UIPopoverPresentationControllerDelegate, FCPublicationRegistrationsFetcherDelegate, PublicationDetailsOptionsMenuPopUpTVCDelegate {
    
    var deleteDelgate: UserDidDeletePublicationProtocol?
    
    var publication: FCPublication?
    var state = PublicationDetailsTVCViewState.Collector
    var referral = PublicationDetailsTVCVReferral.MyPublications
    var publicationIndexNumber = 0
 
    var photoPresentorNavController: FCPhotoPresentorNavigationController!
    var publicationReportsNavController: FCPublicationReportsNavigationController!
    
    weak var actionsHeaderView: PublicationDetsilsCollectorActionsHeaderView?
    
    func setupWithState(initialState: PublicationDetailsTVCViewState, caller: PublicationDetailsTVCVReferral, publication: FCPublication?, publicationIndexPath:Int = 0) {
        // This function is executed before viewDidLoad()

        self.state = initialState
        self.publication = publication
        self.referral = caller
        self.publicationIndexNumber = publicationIndexPath
        
        /*
        // This is for a future implementation (if needed)
        if self.state == PublicationDetailsTVCViewState.Collector {
            // Some code
        }
        else {
            // Some code
        }

        if self.state == PublicationDetailsTVCViewState.Publisher {
            // Some code
        }
        */
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 65
        self.title = publication?.title
        fetchPublicationReports()
        fetchPublicationPhoto()
        fetchPublicationRegistrations()
        registerForNotifications()
        addTopRightButton(self.state)
        configAdminIfNeeded()
       // showOnSpotReport()
    }
    
    //tests only
    func showOnSpotReport() {
    
        let arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
        
        arrivedToSpotReportVC.publication = self.publication
        
        let navController = UINavigationController(rootViewController: arrivedToSpotReportVC) as UINavigationController
        
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    //end tests
    
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
            header?.delegate = self
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
                cell.delegate = self
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
            
            self.displayReportsWithFullScreen()
        }
    }
    
    
    func fetchPublicationPhoto() {
        if let publication = self.publication {
            if publication.photoData.photo == nil && !publication.photoData.didTryToDonwloadImage {
                
                
                let fetcher = FCPhotoFetcher()
                fetcher.fetchPhotoForPublication(publication, completion: { (image: UIImage?) -> Void in
                    if publication.photoData.photo != nil {
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
            FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, completion: { (success: Bool, reports: [FCOnSpotPublicationReport]?) -> () in
                
                if success {
                    if let incomingReports = reports {
                        publication.reportsForPublication = incomingReports
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
                        })
                    }
                }
            })
        }
    }
    
    func fetchPublicationRegistrations() {
    
        if let publication = self.publication {
            
            let fetcher = FCPublicationRegistrationsFetcher(publication: publication)
            fetcher.delegate = self
            fetcher.fetchPublicationRegistration(false)
        }
    }
    
    func didFinishFetchingPublicationRegistrations() {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PublicationDetailsImageCell
        if let imageCell = cell {
            imageCell.reloadRegisteredUserIconCounter()
        }
    }
    
    //MARK: - Remote Notification Handling
    func didDeletePublication(notification: NSNotification) {
        
        let publicationIdentifier = FCUserNotificationHandler.sharedInstance.recivedtoDelete.last
        
        if let identifier = publicationIdentifier {
            
            if let publication = self.publication {
                
                if identifier.uniqueId == publication.uniqueId && identifier.version == publication.version{
                    
                    let alert = UIAlertController(title: publication.title, message: kpublicationDeletedAlertMessage, preferredStyle: .Alert)
                    // Localization: Original string = title: "okay"
                    let action = UIAlertAction(title: "אישור", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func didRecievePublicationRegistration(notification: NSNotification) {
        
        let info = notification.userInfo as? [String : AnyObject]
        
        if let userInfo = info {
            
            let publication = userInfo["publication"] as! FCPublication
            if let presentedPublication = self.publication {
                
                if  presentedPublication.uniqueId == publication.uniqueId &&
                    presentedPublication.version == publication.version {
                        
                        let imageCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PublicationDetailsImageCell
                        if let cell = imageCell {
                         
                            cell.reloadRegisteredUserIconCounter()
                            self.showNewRegistrationBanner()
                        }
                }
            }
        }
    }
    
    func showNewRegistrationBanner() {
        
        let newRgistrationBannerView = NewRegistrationBannerView.loadFromNibNamed("NewRegistrationBannerView", bundle: nil) as! NewRegistrationBannerView
        newRgistrationBannerView.userCreatedPublication = self.publication
        
        let kNewRegistrationBannerHiddenY: CGFloat = -80
        
        newRgistrationBannerView.frame = CGRectMake(0, kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 66)
        self.view.addSubview(newRgistrationBannerView)
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            newRgistrationBannerView.alpha = 1
            newRgistrationBannerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 66)
            
            }) { (finished) -> Void in
                
                UIView.animateWithDuration(0.3, delay: 5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    
                    newRgistrationBannerView.frame = CGRectMake(0, kNewRegistrationBannerHiddenY , CGRectGetWidth(self.view.bounds), 66)
                    newRgistrationBannerView.alpha = 0
                    
                    
                    }){ (finished) -> Void in
                        
                        newRgistrationBannerView.removeFromSuperview()
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

//MARK: - Collector Actions Header delegate

extension FCPublicationDetailsTVC: PublicationDetsilsCollectorActionsHeaderDelegate {
    
    
    func didRegisterForPublication(publication: FCPublication) {
        //print("didRegisterForPublication")
        if publication.typeOfCollecting == TypeOfCollecting.ContactPublisher {
            showPickupRegistrationAlert()
        }
        else {
            registerUserForPublication()
        }
    }
    
    func didUnRegisterForPublication(publication: FCPublication) {
        
        publication.didRegisterForCurrentPublication = false
        publication.countOfRegisteredUsers -= 1
        FCModel.sharedInstance.foodCollectorWebServer.unRegisterUserFromComingToPickUpPublication(publication, completion: { (success) -> Void in})
        FCModel.sharedInstance.savePublications()
        self.updateRegisteredUserIconCounter()
        animateRegistrationButton() 
    }
    
    func didRequestNavigationForPublication(publication: FCPublication) {
        
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"waze://")!)){
            let title = String.localizedStringWithFormat("ניווט בעזרת:", "an action sheet title meening chose app to navigate with")
            let actionSheet = FCAlertsHandler.sharedInstance.navigationActionSheet(title, publication: publication)
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
        else {
            //navigateWithWaze
            FCNavigationHandler.sharedInstance.wazeNavigation(publication)
        }
    }
    
    func didRequestSmsForPublication(publication: FCPublication) {
        
        if let phoneNumber = self.publication?.contactInfo {
            
            if MFMessageComposeViewController.canSendText() {
                
                let messageVC = MFMessageComposeViewController()
                messageVC.body = String.localizedStringWithFormat("רוצה לבוא לאסוף \(publication.title)", "sms message to be sent to the publisher sayin i want to come pick up")
                messageVC.recipients = [phoneNumber]
                messageVC.messageComposeDelegate = self
                self.navigationController?.presentViewController(messageVC, animated: true, completion: nil)
                
            }
        }
    }
    
    func didRequestPhoneCallForPublication(publication: FCPublication) {
        
        if let phoneNumber = self.publication?.contactInfo {
            
            let telUrl = NSURL(string: "tel://\(phoneNumber)")!

            if UIApplication.sharedApplication().canOpenURL(telUrl){
                
                UIApplication.sharedApplication().openURL(telUrl)
            }
        }
    }
    
    private func registerUserForPublication() {
        publication!.didRegisterForCurrentPublication = true
        publication!.countOfRegisteredUsers += 1
        FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(publication!)
        FCModel.sharedInstance.savePublications()
        
        self.updateRegisteredUserIconCounter()
        self.animateRegistrationButton()
    }

    private func animateRegistrationButton() {
        actionsHeaderView?.animateButton((actionsHeaderView?.registerButton)!)
        actionsHeaderView?.configureRegisterButton()
    }
    
    private func updateRegisteredUserIconCounter() {
        
        let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let imageCell = self.tableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
        if let cell = imageCell {
            cell.reloadRegisteredUserIconCounter()
        }
    }
    
    func showPickupRegistrationAlert() {
        // The user is prompt to register to the event as a picker using a name and a phone number
        // Set string labels for the alert
        //print("showPickupRegistrationAlert")
        let alertTitle = String.localizedStringWithFormat("רישום לאיסוף", "Alert title: Pickup Registration")
        let alertMessage = String.localizedStringWithFormat("יש למלא פרטי התקשרות כדי להצטרף לאיסוף", "Alert message: Please fill in details to join this pickup")
        let alertRegisterButtonTitle = String.localizedStringWithFormat("הרשמה", "Alert button title: Register")
        let alertCancelButtonTitle = String.localizedStringWithFormat("ביטול", "Alert button title: Cancel")
        let alertNameTextFieldLabel = String.localizedStringWithFormat("שם", "Alert text field label: Name")
        let alertPhoneTextFieldLabel = String.localizedStringWithFormat("מספר טלפון", "Alert text field label: Phone number")
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add text fields
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            if User.sharedInstance.userName != "" {
                textField.text = User.sharedInstance.userName
            }
            else {
                textField.placeholder = alertNameTextFieldLabel
            }
            textField.textAlignment = NSTextAlignment.Right
        })
        
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            if User.sharedInstance.userPhoneNumber != "" {
                textField.text = User.sharedInstance.userPhoneNumber
            }
            else {
                textField.placeholder = alertPhoneTextFieldLabel
            }
            textField.textAlignment = NSTextAlignment.Right
            textField.keyboardType = UIKeyboardType.NumberPad
        })
        
        // Add buttons
        alertController.addAction(UIAlertAction(title: alertRegisterButtonTitle, style: UIAlertActionStyle.Default,handler: { (action) -> Void in
            let name = (alertController.textFields![0] as UITextField).text
            let number = (alertController.textFields![1] as UITextField).text
            if (name == "" ||  number == "") {
                self.showNoNameOrNumberAllert()
            }
            else {
                self.registerUser(name!, number: number!, publication: self.publication!)
            }
        }))
        alertController.addAction(UIAlertAction(title: alertCancelButtonTitle, style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    private func registerUser(name: String, number: String, publication: FCPublication) {
        User.sharedInstance.setUserName(name)
        
        // Get and check if phone number is valid or a nil
        if Validator().getValidPhoneNumber(number) == nil {
            showPhoneNumberAllert()
        }
        else {
            User.sharedInstance.setUserPhoneNumber(number)
            
            registerUserForPublication()
        }
    }
    
    private func showNoNameOrNumberAllert() {
        
        let alertTitle = String.localizedStringWithFormat("אופס...", "Alert title: Ooops...")
        let alertMessage = String.localizedStringWithFormat("חובה למלא את כל השדות", "Alert message: You have to fill all the fields")
        let alertButtonTitle = String.localizedStringWithFormat("אישור", "Alert button title: OK")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: alertButtonTitle, style: UIAlertActionStyle.Default,handler: { (alertAction: UIAlertAction) -> Void in
            self.showPickupRegistrationAlert()
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showPhoneNumberAllert() {
        
        let alertTitle = String.localizedStringWithFormat("אופס...", "Alert title: Ooops...")
        let alertMessage = String.localizedStringWithFormat("נראה שמספר הטלפון לא תקין. אנא בידקו שהקלדתם נכון", "Alert message: It seems the phone number is incorrect. Please chaeck you have typed correctly.")
        let alertButtonTitle = String.localizedStringWithFormat("אישור", "Alert button title: OK")
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: alertButtonTitle, style: UIAlertActionStyle.Default,handler: { (alertAction: UIAlertAction) -> Void in
                self.showPickupRegistrationAlert()
        
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
}

//MARK: - Publisher Actions Header delegate

extension FCPublicationDetailsTVC: PublicationDetsilsPublisherActionsHeaderDelegate {
    
    
    func didRequestPostToFacebookForPublication() {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let facebookPostController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookPostController.setInitialText(publication?.title)
            facebookPostController.addImage(publication?.photoData.photo)
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
            twiiterPostController.addImage(publication?.photoData.photo)
            twiiterPostController.addURL(NSURL(string: "https://www.facebook.com/foodonet"))
            self.presentViewController(twiiterPostController, animated:true, completion:nil)
        }
    }
    
    func publisherDidRequestSmsCollectors() {
        
        if publication?.registrationsForPublication.count == 0 {
            let title = String.localizedStringWithFormat("אין משתמשים בדרך לאסוף", "")
            presentNoCollectorsAlert(title)
            return
        }
        
        let validator = Validator()
        let trueNumbers = publication?.registrationsForPublication.filter {(registration) in validator.getValidPhoneNumber(registration.contactInfo) != nil}
        if trueNumbers == nil || trueNumbers?.count == 0 {
            let title = String.localizedStringWithFormat("אין מספרי טלפון חוקיים", "")
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
    
        if publication?.registrationsForPublication.count == 0 {
            
            let title = String.localizedStringWithFormat("אין משתמשים בדרך לאסוף", "")
            presentNoCollectorsAlert(title)
            return
        }
        
        //present ContactCollectorPhonePicker
        let contactCollectorPhonePickerNavVC = storyboard?.instantiateViewControllerWithIdentifier("ContactCollectorPhonePickerNavVC") as! UINavigationController
        contactCollectorPhonePickerNavVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        contactCollectorPhonePickerNavVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        let contactCollectorPhonePicker = contactCollectorPhonePickerNavVC.viewControllers[0] as! ContactCollectorPhonePickerVC
        contactCollectorPhonePicker.registrations = self.publication!.registrationsForPublication
        self.navigationController?.presentViewController(contactCollectorPhonePickerNavVC, animated: true, completion: nil)
    }
    
    func presentNoCollectorsAlert(title: String) {
        
        let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(title, aMessage: "")
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
}


//MARK: - Image cell delegate

extension FCPublicationDetailsTVC : PublicationDetailsImageCellDelegate {
    
    
    func didRequestFullScreenImage() {
        self.presentPhotoPresentor()
    }
    
    func presentPhotoPresentor() {
        
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
}

extension FCPublicationDetailsTVC: UIViewControllerTransitioningDelegate {
    
    //MARK: - Transition Delegate
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
       
        var pcontrol: UIPresentationController!
        
        if presented is FCPhotoPresentorNavigationController {
            
            pcontrol = PublicationPhotoPresentorPresentationController(
            presentedViewController: self.photoPresentorNavController,
            presentingViewController: self.navigationController!)
        }
        
        else if presented is FCPublicationReportsNavigationController{
            
            pcontrol = FCPublicationReportsPresentationController( presentedViewController: self.publicationReportsNavController,
                presentingViewController: self.navigationController!)
        }
        
        return  pcontrol
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        //starting frame for transition
        if presented is FCPhotoPresentorNavigationController {

            let photoPresentorVCAnimator = PublicationPhotoPresentorAnimator()

            var originFrame = CGRectZero
            //TODO: set initial photo frame
            let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
            let imageCell = self.tableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
            if let cell = imageCell {
                originFrame = self.view.convertRect(cell.publicationImageView.frame, fromView: cell)
            }
            
            photoPresentorVCAnimator.originFrame = originFrame
            return photoPresentorVCAnimator
        }
        
        else if presented is FCPublicationReportsNavigationController{
            
            let publicationReportsAnimator = FCPublicationReportsVCAnimator()
            var startingFrame = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
    //        startingFrame.origin.y += kTableViewHeaderHeight
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
            
            let destinationFrame =
            self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            
            animator.destinationRect = destinationFrame
            
            return animator
        }
        
        return nil
    }
}

extension FCPublicationDetailsTVC {
    //MARK: - reports cell full screen
    

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

//MARK: - SMS Message Composer

extension FCPublicationDetailsTVC : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
        
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
       
        case MessageComposeResultFailed.rawValue:
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

            
            let alert = UIAlertController(title: "שליחת ההודעה נכשלה", message: "לנסות שוב?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "כן", style: .Default , handler: { (action) -> Void in
                self.didRequestSmsForPublication(self.publication!)
            }))
            alert.addAction(UIAlertAction(title: "לא", style: .Cancel, handler: { (action) -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
}

//MARK: - Report Button and delegate

extension FCPublicationDetailsTVC : FCOnSpotPublicationReportDelegate {
    
//    func addReportButton() {
//     
//        if !FCModel.sharedInstance.isUserCreaetedPublication(self.publication!){
//            let title = kReportButtonTitle
//            let reportButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: "presentReportVC")
//            self.navigationItem.setRightBarButtonItem(reportButton, animated: false)
//        }
//    }
    
    func addTopRightButton(buttonType: PublicationDetailsTVCViewState) {
        var buttonValus = (kReportButtonTitle, "presentReportVC")
        
        if buttonType == PublicationDetailsTVCViewState.Publisher {
            buttonValus = (kOptionsButtonTitle, "presentOptionsMenuVC")
        }
            
        createTopRightButton(label: buttonValus.0, andAction: buttonValus.1)
    }
    
    func createTopRightButton(label label:String, andAction actionName: String) {
        let actionSelector = Selector(stringLiteral: actionName)
        let topRightButton = UIBarButtonItem(
                title: label,
                style: UIBarButtonItemStyle.Done,
                target: self,
                action: actionSelector)
        self.navigationItem.setRightBarButtonItem(topRightButton, animated: false)
    }
    
    
    func presentReportVC() {
        
        let arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
        
        arrivedToSpotReportVC.publication = self.publication
        arrivedToSpotReportVC.delegate = self

        let navController = UINavigationController(rootViewController: arrivedToSpotReportVC) as UINavigationController
        
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    func presentOptionsMenuVC(){
        let optionsMenuPopUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("publisherOptionsMenuVC") as! PublicationOptionsMenuTVC
        optionsMenuPopUpVC.delegate = self
        optionsMenuPopUpVC.publication = publication
        
        optionsMenuPopUpVC.popoverPresentationController?.delegate = self
        optionsMenuPopUpVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        if publication!.isOnAir {
            // 44 is the row height of each cell in the options menu table
            optionsMenuPopUpVC.preferredContentSize = CGSizeMake(150, (44*3-1))
        }
        else {
            optionsMenuPopUpVC.preferredContentSize = CGSizeMake(150, (44*2-1))
        }

        //get the popup presentation controller. it is a property on every
        //View Controller subclass. there you set the arrows direction etc. take a look at
        //it's properties, it's very flexible.
        
        
        let popUpPC = optionsMenuPopUpVC.popoverPresentationController
        popUpPC?.delegate = self
        popUpPC?.permittedArrowDirections = UIPopoverArrowDirection.Up
        popUpPC?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        self.presentViewController(optionsMenuPopUpVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    func dismiss() {
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

//MARK: - Admin for beta bundle

extension FCPublicationDetailsTVC {
    
    func configAdminIfNeeded() {
        
        var infoPlist: NSDictionary?
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType:"plist") {
            
            infoPlist = NSDictionary(contentsOfFile: path)
        }
        
        if let infoPlist = infoPlist {
            
            let bundleName = infoPlist["CFBundleName"] as! String
            let bundleID = infoPlist["CFBundleIdentifier"] as! String
            print("BUNDLE ID: \(bundleID)")
            if bundleName.hasPrefix("beta") {
             
                print("Beta Version. adding deleteButton")
                addDeletButton()
            }
        }
        else {
            print("Config Admin **************: NOT FOUND")
            
        }
    }
    
    func addDeletButton() {
        
        let deleteButton = UIBarButtonItem(title: "delete", style: UIBarButtonItemStyle.Plain, target: self, action: "deletePublication")
        self.navigationItem.setRightBarButtonItem(deleteButton, animated: false)
    }
    
    func deletePublication() {
        print("deleting publication")
        
        let identifier = PublicationIdentifier(uniqueId: self.publication!.uniqueId , version: self.publication!.version)
        
        FCModel.sharedInstance.foodCollectorWebServer.deletePublication(identifier, completion: { (success) -> () in
            
        })
    }
}

//MARK: - PublicationDetailsOptionsMenuPopUpTVCDelegate Protocol

extension FCPublicationDetailsTVC {
    
    func didSelectEditPublicationAction(){
     //   dismiss()

        let publicationEditorTVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublicationEditorTVC") as? PublicationEditorTVC
        let identifier = PublicationIdentifier(uniqueId: publication!.uniqueId , version: publication!.version)
        guard let userCreatedPublication = FCModel.sharedInstance.userCreatedPublicationWithIdentifier(identifier) else {return}
        userCreatedPublication.photoData.photo = publication?.photoData.photo
        publicationEditorTVC?.setupWithState(.EditPublication, publication: userCreatedPublication)
        
        
        let nav = UINavigationController(rootViewController: publicationEditorTVC!)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)

    }
    
    func didSelectTakOffAirPublicationAction() {
        
        let takeOffAirAlert = UIAlertController(title: kTakeOffAirlertTitle, message: kTakeOffAirAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        takeOffAirAlert.addAction(UIAlertAction(title: kAlertOKButtonTitle, style: .Default, handler: { (action: UIAlertAction!) in
            self.deleteDelgate?.didTakeOffAirPublication(self.publication!)
        }))
        
        takeOffAirAlert.addAction(UIAlertAction(title: kAlertCancelButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
        }))
        
        presentViewController(takeOffAirAlert, animated: true, completion: nil)
        
    }
    
    func didSelectDeletePublicationAction() {
        
        let deleteAlert = UIAlertController(title: kDeleteAlertTitle, message: kDeleteAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: kAlertOKButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
            
            let pubicationToDelete = self.publication!
            // make identifier. we append it to the notification handler since PublicationsTVC will fetch it from there
            let publicationIdentifier = PublicationIdentifier(uniqueId: pubicationToDelete.uniqueId , version: pubicationToDelete.version)
            FCUserNotificationHandler.sharedInstance.recivedtoDelete.append(publicationIdentifier)
            
            
            //delete from model
            FCModel.sharedInstance.deletePublication(publicationIdentifier, deleteFromServer: true, deleteUserCreatedPublication: true)
            
                self.deleteDelgate?.didDeletePublication(pubicationToDelete, collectionViewIndex: self.publicationIndexNumber)
            
            //self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: kAlertCancelButtonTitle, style: .Default, handler: nil))
        
        self.presentViewController(deleteAlert, animated: true, completion: nil)

    }
    
    func reload() {
        print("reload")
        self.tableView.reloadData()
    }
}




