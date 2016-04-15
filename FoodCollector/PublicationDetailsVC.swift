//
//  PublicationDetailsVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 3.4.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import MessageUI
import Social
import CoreData


let kReportButtonTitle = NSLocalizedString("Report", comment:"Report title for a button")
let kOptionsButtonTitle = NSLocalizedString("Options", comment:"Report title for a button")
let kTakeOffAirlertTitle = NSLocalizedString("Confirm Event Ended", comment:"End publication confirmation title for an alert controller")
let kDeleteAlertTitle = NSLocalizedString("Delete Event?", comment:"Delete confirmation title for an alert controller")


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


class PublicationDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FCPublicationRegistrationsFetcherDelegate, PublicationDetailsOptionsMenuPopUpTVCDelegate, UIPopoverPresentationControllerDelegate {
    
    weak var deleteDelgate: UserDidDeletePublicationProtocol?
    
    var publication: Publication?
    var state = PublicationDetailsTVCViewState.Collector
    var referral = PublicationDetailsTVCVReferral.MyPublications
    var publicationIndexNumber = 0
    
    var photoPresentorNavController: FCPhotoPresentorNavigationController!
    var publicationReportsNavController: FCPublicationReportsNavigationController!
    
    weak var actionsHeaderView: PublicationDetsilsCollectorActionsHeaderView?
    
    
    // MARK: - @IBOutlet Variables
    
    @IBOutlet weak var registeredUsersCounterLabel: UILabel!
    
    @IBOutlet weak var endOfPublicationTimelabel: UILabel!
    
    @IBOutlet weak var targetAudienceLabel: UILabel!
    
    @IBOutlet weak var targetAudienceIcon: UIImageView!
    
    @IBOutlet weak var shareDetailsTableView: UITableView!
    
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var smsButton: UIButton!
    
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var goButton: UIButton!
    
    
    // MARK: - @IBAction Functions
    @IBAction func joinButtonClicked(sender: UIButton) {
        if let publication = self.publication {
            switch publication.didRegisterForCurrentPublication!.boolValue {
            case true:
                self.didUnRegisterForPublication(publication)
            case false:
                self.didRegisterForPublication(publication)
            }
        }
    }
    
    @IBAction func smsButtonClicked(sender: UIButton) {
        if let publication = self.publication {
            self.didRequestSmsForPublication(publication)
        }
        
        GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Collector sms button", label: "", value: 0)
    }
    
    @IBAction func callButtonClicked(sender: UIButton) {
        if let publication = self.publication {
            self.didRequestPhoneCallForPublication(publication)
        }
        
        GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Collector phone call button", label: "", value: 0)
    }
    
    @IBAction func goButtonClicked(sender: UIButton) {
        if let publication = self.publication {
            if !publication.didRegisterForCurrentPublication!.boolValue{
                self.didRegisterForPublication(publication)
            }
            self.didRequestNavigationForPublication(publication)
        }
        
        GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Collector navigation button", label: "", value: 0)
    }
    
    
    
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
        
        self.shareDetailsTableView.registerNib(UINib(nibName: "PublicationDetailsImageTVCell", bundle: nil), forCellReuseIdentifier: "detailsImageTVCell")
        
        self.shareDetailsTableView.registerNib(UINib(nibName: "PublicationDetailsTitleTVCell", bundle: nil), forCellReuseIdentifier: "detailsTitleTVCell")
        
        self.shareDetailsTableView.registerNib(UINib(nibName: "PublicationDetailsDetailsTVCell", bundle: nil), forCellReuseIdentifier: "detailsDetailsTVCell")
        
        self.shareDetailsTableView.registerNib(UINib(nibName: "PublicationDetailsMoreInfoTVCell", bundle: nil), forCellReuseIdentifier: "detailsMoreInfoTVCell")
        
        self.shareDetailsTableView.registerNib(UINib(nibName: "PublicationDetailsRepotsTVCell", bundle: nil), forCellReuseIdentifier: "detailsRepotsTVCell")
        
        //shareDetailsTableView.dataSource = self
        //shareDetailsTableView.delegate = self
        //self.tableView.estimatedRowHeight = 65
        fetchPublicationReports()
        fetchPublicationPhoto()
        //fetchPublicationRegistrations()
        registerForNotifications()
        addTopRightButton(self.state)
        configAdminIfNeeded()
        
        reloadRegisteredUserIconCounter()

        shareDetailsTableView.estimatedRowHeight = 40

        
        // This will eliminate the 1px dark shadow strip under the navbar.
        if let navBar =  self.navigationController?.navigationBar {
            //navBar.translucent = false
            navBar.clipsToBounds = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let pub = publication {
            endOfPublicationTimelabel.text = FCDateFunctions.timeStringDaysAndHoursRemainVerbose(fromDate: pub.endingData!, toDate: NSDate())
            targetAudienceIcon.image = FCIconFactory.typeOfPublicationIconWhite(pub)
            
            if let group = Group.fetchGroupWithId(pub.audianceID) {
                if let groupName = group.name {
                    targetAudienceLabel.text = groupName
                }
            }
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView Functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {return 4}
        
        return PublicationDetailsReportCell.numberOfReportsToPresent(self.publication)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return view.frame.size.height * 0.1936 // Image Cell
            }
        }
        else {
            return 22 // Report cell(s)
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            switch indexPath.row {
            case 0: // Image cell
                let cell = tableView.dequeueReusableCellWithIdentifier("detailsImageTVCell", forIndexPath: indexPath) as! PublicationDetailsImageTVCell
                if let data = self.publication?.photoBinaryData {
                    print("Image Data!!!!")
                    let photo = UIImage(data: data)
                    cell.shareDetailsImage = UIImageView(image: photo)
                }
                return cell
                
            case 1: // Title cell
                let cell = tableView.dequeueReusableCellWithIdentifier("detailsTitleTVCell", forIndexPath: indexPath) as! PublicationDetailsTitleTVCell
                cell.shareDetailsTitle.text = publication?.title
                return cell
                
            case 2: // Details Cell
                let cell = tableView.dequeueReusableCellWithIdentifier("detailsDetailsTVCell", forIndexPath: indexPath) as! PublicationDetailsDetailsTVCell
                //cell.shareUserImage = publication.????
                //cell.shareUserNameLabel = publication.????
                cell.shareLocationLabel.text = publication?.address
                return cell
                
            case 3: // More Info Cell
                let cell = tableView.dequeueReusableCellWithIdentifier("detailsMoreInfoTVCell", forIndexPath: indexPath) as! PublicationDetailsMoreInfoTVCell
                cell.shareDetailsMorInfo.text = publication?.subtitle
                return cell
                
            default:
                break
            }
            
        case 1:
            
            switch indexPath.row {
            case 0: // Reports cell
                let cell = tableView.dequeueReusableCellWithIdentifier("detailsRepotsTVCell", forIndexPath: indexPath) as! PublicationDetailsRepotsTVCell
                cell.indexPath = indexPath
                cell.publication = self.publication
                return cell
            default:
                break
            }
            
        default:
            break
        }
        
        
        return UITableViewCell()
    }
    
    
    // MARK: - Fetch Data For Publication
    
    func fetchPublicationPhoto() {
        if let publication = self.publication {
            if publication.photoBinaryData == nil && !publication.didTryToDownloadImage!.boolValue {
                
                
                let fetcher = FCPhotoFetcher()
                fetcher.fetchPhotoForPublication(publication, completion: { (image: UIImage?) -> Void in
                    
                    if image != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                            let imageCell = self.shareDetailsTableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
                            if let cell = imageCell {
                                cell.reloadPublicationImage()
                            }
                        })
                    }
                })
            }
        }
    }
    
    func fetchPublicationReports() {
        
        if let publication = self.publication {
            
            let localContext = FCModel.dataController.createPrivateQueueContext()
            
            localContext.performBlock({ () -> Void in
                
                FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, context: localContext, completion: { (success) -> Void in
                    
                    if success {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //self.shareDetailsTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
                            self.shareDetailsTableView.reloadData()
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
    
    final func reloadRegisteredUserIconCounter() {
        
        if let registrations = self.publication?.registrations {
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                
                self.registeredUsersCounterLabel.alpha = 0
                
                }) { (finished) -> Void in
                    var registeredUsersCounterlabelText = ""
                    switch registrations.count {
                    case 0: // No users registered
                        registeredUsersCounterlabelText = NSLocalizedString("No users joined", comment:"Displays how many are registered and joined a publication.")
                    case 1: // One user registered
                        registeredUsersCounterlabelText = NSLocalizedString("1 user joined", comment:"Displays how many are registered and joined a publication.")
                    default: // More than one user registered
                        registeredUsersCounterlabelText = String.localizedStringWithFormat(NSLocalizedString("%@ users joined", comment:"Displays how many are registered and joined a publication. e.g.: '3 users joined'"), "\(registrations.count)")
                    }
                    
                    self.registeredUsersCounterLabel.text = registeredUsersCounterlabelText
                    //self.defineImageColorForUser()
                    
                    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                        
                        self.registeredUsersCounterLabel.alpha = 1
                        
                        
                        }, completion: nil)}
        }
    }
    
    func didFinishFetchingPublicationRegistrations() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.reloadRegisteredUserIconCounter()
        }
    }
    
    // MARK: - NSNotifications
    func registerForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
        
    }
    
    func didRecievePublicationRegistration(notification: NSNotification) {
        
        let info = notification.userInfo as? [String : AnyObject]
        if let userInfo = info {

            let publication = userInfo["publication"] as! Publication
            if let presentedPublication = self.publication {

                if  presentedPublication.uniqueId == publication.uniqueId &&
                    presentedPublication.version == publication.version {

                        reloadRegisteredUserIconCounter()
                }
            }
        }
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

extension PublicationDetailsVC: PublicationDetsilsCollectorActionsHeaderDelegate {
    
    
    func didRegisterForPublication(publication: Publication) {
        // If the user is logged in: register him to this pickup.
        // If the user is NOT logged in: start login process.
        
        if User.sharedInstance.userIsLoggedIn {
            registerUserForPublication()
        }
        else {
            showNotLoggedInAlert()
        }
    }
    
    func didUnRegisterForPublication(publication: Publication) {
        
        publication.didRegisterForCurrentPublication = false
        FCModel.sharedInstance.removeRegistrationFor(publication)
        reloadRegisteredUserIconCounter()
        //animateRegistrationButton()
    }
    
    func didRequestNavigationForPublication(publication: Publication) {
        
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"waze://")!)){
            let title = NSLocalizedString("Navigate with:", comment:"an action sheet title meening chose app to navigate with")
            let actionSheet = FCAlertsHandler.sharedInstance.navigationActionSheet(title, publication: publication)
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
        else {
            //navigateWithWaze
            FCNavigationHandler.sharedInstance.wazeNavigation(publication)
        }
    }
    
    func didRequestSmsForPublication(publication: Publication) {
        if let phoneNumber = self.publication?.contactInfo {
            if MFMessageComposeViewController.canSendText() {
                let messageVC = MFMessageComposeViewController()
                messageVC.body = String.localizedStringWithFormat(NSLocalizedString("I want to pickup %@", comment:"SMS message body: I want to pickup 'Publication name'"), publication.title!)
                messageVC.recipients = [phoneNumber]
                //messageVC.messageComposeDelegate = self
                self.navigationController?.presentViewController(messageVC, animated: true, completion: nil)
                
            }
        }
    }
    
    func didRequestPhoneCallForPublication(publication: Publication) {
        
        if let phoneNumber = self.publication?.contactInfo {
            
            let telUrl = NSURL(string: "tel://\(phoneNumber)")!
            
            if UIApplication.sharedApplication().canOpenURL(telUrl){
                
                UIApplication.sharedApplication().openURL(telUrl)
            }
        }
    }
    
    private func registerUserForPublication() {
        publication!.didRegisterForCurrentPublication = true
        FCModel.sharedInstance.addRegisterationFor(publication!)
        reloadRegisteredUserIconCounter()
        //self.animateRegistrationButton()
    }
    
//    private func animateRegistrationButton() {
//        actionsHeaderView?.animateButton((actionsHeaderView?.registerButton)!)
//        actionsHeaderView?.configureRegisterButton()
//    }
    
    
    
    func showNotLoggedInAlert() {
        let alertController = UIAlertController(title: kAlertLoginTitle, message: kAlertLoginMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add buttons
        alertController.addAction(UIAlertAction(title: kAlertLoginButtonTitle, style: UIAlertActionStyle.Default,handler: { (action) -> Void in
            self.startLoginprocess()
        }))
        alertController.addAction(UIAlertAction(title: kCancelButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func startLoginprocess() {
        print("startLoginprocess")
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let identityProviderLogingViewNavVC = loginStoryboard.instantiateViewControllerWithIdentifier("IdentityProviderLoginNavVC") as! UINavigationController
        
        self.presentViewController(identityProviderLogingViewNavVC, animated: true, completion: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
}

extension PublicationDetailsVC {
    //MARK: - reports cell full screen
    
    
    func displayReportsWithFullScreen() {
        
        let reports = publication?.reports
        
        if reports == nil || reports?.count == 0 {return}
        
        
        let publicationReportsNavController = self.storyboard?.instantiateViewControllerWithIdentifier("publicationReportsNavController") as! FCPublicationReportsNavigationController
        self.publicationReportsNavController = publicationReportsNavController
        
        publicationReportsNavController.transitioningDelegate = self
        publicationReportsNavController.modalPresentationStyle = .Custom
        
        let publicationReportsTVC = publicationReportsNavController.viewControllers[0] as! FCPublicationReportsTVC
        
        publicationReportsTVC.publication = self.publication
        
        self.navigationController?.presentViewController(publicationReportsNavController, animated: true, completion: { () -> Void in})
        
    }
    
}

extension PublicationDetailsVC: UIViewControllerTransitioningDelegate {
    
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
            let imageCell = self.shareDetailsTableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
            if let cell = imageCell {
                originFrame = self.view.convertRect(cell.publicationImageView.frame, fromView: cell)
            }
            
            photoPresentorVCAnimator.originFrame = originFrame
            return photoPresentorVCAnimator
        }
            
        else if presented is FCPublicationReportsNavigationController{
            
            let publicationReportsAnimator = FCPublicationReportsVCAnimator()
            var startingFrame = self.shareDetailsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
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
            self.shareDetailsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            
            animator.destinationRect = destinationFrame
            
            return animator
        }
        
        return nil
    }
}

//MARK: - SMS Message Composer

extension PublicationDetailsVC : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
            
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
        case MessageComposeResultFailed.rawValue:
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
            
            let alert = UIAlertController(title: kSendSMSfailedAlertTitle, message: kSendSMSTryAgainAlertMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default , handler: { (action) -> Void in
                self.didRequestSmsForPublication(self.publication!)
            }))
            alert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Cancel, handler: { (action) -> Void in
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

extension PublicationDetailsVC : FCOnSpotPublicationReportDelegate {
    
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
        
        if User.sharedInstance.userIsLoggedIn {
            let arrivedToSpotReportVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCArrivedToPublicationSpotVC") as! FCArrivedToPublicationSpotVC
            
            arrivedToSpotReportVC.publication = self.publication
            arrivedToSpotReportVC.delegate = self
            
            let navController = UINavigationController(rootViewController: arrivedToSpotReportVC) as UINavigationController
            
            self.navigationController?.presentViewController(navController, animated: true, completion: nil)
        }
        else {
            showNotLoggedInAlert()
        }
    }
    
    //MARK: - Reports delegate
    
    func dismiss(report: PublicationReport?) {
        
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.shareDetailsTableView.reloadData()
        }
    }
    
    //MARK: - Options menue
    func presentOptionsMenuVC(){
        
        if User.sharedInstance.userIsLoggedIn {
            let optionsMenuPopUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("publisherOptionsMenuVC") as! PublicationOptionsMenuTVC
            optionsMenuPopUpVC.delegate = self
            optionsMenuPopUpVC.publication = publication
            
            optionsMenuPopUpVC.popoverPresentationController?.delegate = self
            optionsMenuPopUpVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            if publication!.isOnAir! == true {
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
        else {
            showNotLoggedInAlert()
        }
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    
}

//MARK: - Admin for beta bundle

extension PublicationDetailsVC {
    
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
        
        //        let identifier = PublicationIdentifier(uniqueId: self.publication!.uniqueId!.integerValue , version: self.publication!.version!.integerValue)
        //
        //        FCModel.sharedInstance.foodCollectorWebServer.deletePublication(identifier, completion: { (success) -> () in
        //
        //            if success {
        //                self.dismissViewControllerAnimated(true, completion: nil)
        //            }
        //
        //            else {
        //                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("Error deleting", aMessage: "publication id: \(identifier.uniqueId) version: \(identifier.version) ")
        //                self.presentViewController(alert, animated: true, completion: nil)
        //            }
        //        })
    }
}

//MARK: - PublicationDetailsOptionsMenuPopUpTVCDelegate Protocol

extension PublicationDetailsVC {
    
    func didSelectEditPublicationAction(){
        //   dismiss()
        
        let publicationEditorTVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublicationEditorTVC") as? PublicationEditorTVC
        publicationEditorTVC?.setupWithState(.EditPublication, publication: publication!)
        
        
        let nav = UINavigationController(rootViewController: publicationEditorTVC!)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    func didSelectTakOffAirPublicationAction() {
        
        let takeOffAirAlert = UIAlertController(title: kTakeOffAirlertTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        takeOffAirAlert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default, handler: { (action: UIAlertAction!) in
            self.deleteDelgate?.didTakeOffAirPublication(self.publication!)
        }))
        
        takeOffAirAlert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
        }))
        
        presentViewController(takeOffAirAlert, animated: true, completion: nil)
        
    }
    
    func didSelectDeletePublicationAction() {
        
        let deleteAlert = UIAlertController(title: kDeleteAlertTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        deleteAlert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
            
            //delete from model
            deleteAlert.dismissViewControllerAnimated(true, completion: nil)
            FCModel.sharedInstance.deletePublication(self.publication!, deleteFromServer: true)
            self.deleteDelgate?.didDeletePublication(self.publication!, collectionViewIndex: self.publicationIndexNumber)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Default, handler: nil))
        self.presentViewController(deleteAlert, animated: true, completion: nil)
    }
    
    func reload() {
        print("reload")
        self.shareDetailsTableView.reloadData()
    }
}

