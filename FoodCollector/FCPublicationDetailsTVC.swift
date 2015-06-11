//
//  FCPublicationDetailsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import MessageUI

class FCPublicationDetailsTVC: UITableViewController, UIScrollViewDelegate {
    
    var publication: FCPublication?
 
    var photoPresentorNavController: FCPhotoPresentorNavigationController!
    var publicationReportsNavController: FCPublicationReportsNavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 65
        fetchPublicationReports()
        fetchPublicationPhoto()
        registerForNotifications()
        
        self.title = publication?.title
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
        let header = UIView.loadFromNibNamed("PublicationDetsilsActionsHeaderView", bundle: nil) as? PublicationDetsilsActionsHeaderView
        header?.delegate = self
        header?.publication = self.publication
        return header
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

extension FCPublicationDetailsTVC: PublicationDetailsActionsHeaderDelegate {
    
    //MARK: - Title cell delegate
    
    func didRegisterForPublication(publication: FCPublication) {
        
        publication.didRegisterForCurrentPublication = true
        publication.countOfRegisteredUsers += 1
        FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(publication, message: FCRegistrationForPublication.RegistrationMessage.register)
        FCModel.sharedInstance.savePublications()
        
        self.updateRegisteredUserIconCounter()
        //show alert controller
        if publication.typeOfCollecting == FCTypeOfCollecting.ContactPublisher {
            
            let title = String.localizedStringWithFormat("נא ליצור קשר עם המשתף", "an alert title requesting to contact the publisher")
            let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(title, aMessage: " ")
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func didUnRegisterForPublication(publication: FCPublication) {
        
        publication.didRegisterForCurrentPublication = false
        publication.countOfRegisteredUsers -= 1
        //TODO: Delete registration from server
    //    FCModel.sharedInstance.foodCollectorWebServer.registerUserForPublication(publication, message: FCRegistrationForPublication.RegistrationMessage.unRegister)
        FCModel.sharedInstance.savePublications()
        self.updateRegisteredUserIconCounter()

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

    private func updateRegisteredUserIconCounter() {
        
        let imageCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let imageCell = self.tableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageCell
        if let cell = imageCell {
            cell.reloadRegisteredUserIconCounter()
        }
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
}

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
            
            var publicationReportsAnimator = FCPublicationReportsVCAnimator()
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
            
            var destinationFrame =
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

extension FCPublicationDetailsTVC : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.value) {
        
        case MessageComposeResultCancelled.value:
            println("Message was cancelled")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
       
        case MessageComposeResultFailed.value:
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

            
            let alert = UIAlertController(title: "שליחת ההודעה נכשלה", message: "לנסות שוב?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "כן", style: .Default , handler: { (action) -> Void in
                self.didRequestSmsForPublication(self.publication!)
            }))
            alert.addAction(UIAlertAction(title: "לא", style: .Cancel, handler: { (action) -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            
        case MessageComposeResultSent.value:
            println("Message was sent")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
}