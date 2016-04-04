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


class PublicationDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FCPublicationRegistrationsFetcherDelegate, PublicationDetailsOptionsMenuPopUpTVCDelegate {
    
    weak var deleteDelgate: UserDidDeletePublicationProtocol?
    
    var publication: Publication?
    var state = PublicationDetailsTVCViewState.Collector
    var referral = PublicationDetailsTVCVReferral.MyPublications
    var publicationIndexNumber = 0
    
    var photoPresentorNavController: FCPhotoPresentorNavigationController!
    var publicationReportsNavController: FCPublicationReportsNavigationController!

    @IBOutlet weak var shareDetailsTableView: UITableView!
    
    
    
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
        
        //shareDetailsTableView.dataSource = self
        //shareDetailsTableView.delegate = self
        //self.tableView.estimatedRowHeight = 65
        fetchPublicationReports()
        fetchPublicationPhoto()
        //fetchPublicationRegistrations()
        registerForNotifications()
        addTopRightButton(self.state)
        configAdminIfNeeded()
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0: // Image Cell
            return 220
        case 1: // Title Cell
            return 40
        case 2: // Details Cell
            return 40
        case 3: // More Info Cell
            return 40
        case 4: // Reports Cell
            return 40
        default:
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0: //Image cell
            let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsImageCell", forIndexPath: indexPath) as! PublicationDetailsImageCell
            cell.delegate = self
            cell.publication = self.publication
            return cell
        
        case 1: //Title cell
            let cell = tableView.dequeueReusableCellWithIdentifier("PublicationDetailsTitleCellTableViewCell", forIndexPath: indexPath) as! PublicationDetailsTitleCellTableViewCell
            cell.publication = self.publication
            return cell
            
        
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
                            self.shareDetailsTableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
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
            let cell = self.shareDetailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? PublicationDetailsImageCell
            if let imageCell = cell {
                imageCell.reloadRegisteredUserIconCounter()
            }
        }
    }
    
    // MARK: - NSNotifications
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
            self.tableView.reloadData()
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
        self.tableView.reloadData()
    }
}

