//
//  FCPublicationDetailsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationDetailsTVC: UITableViewController, FCPublicationDetailsTitleCellDelegate, UIScrollViewDelegate {
    
    var publication: FCPublication?
    
    private let kTableViewHeaderHeight: CGFloat = 300.0
    var headerView: FCPublicationDetailsTVHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = self.tableView.tableHeaderView as FCPublicationDetailsTVHeaderView
        self.tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        headerView.publication = self.publication
        
        self.tableView.contentInset = UIEdgeInsets(top: kTableViewHeaderHeight, left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset = CGPointMake(0, -kTableViewHeaderHeight)
        updateHeaderView()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 140
        fetchPublicationReports()
        fetchPublicationPhoto()
        registerForNotifications()
     
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
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //change to 4 if we want the photo cell down
        return 3
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationsDetailsTVTitleCell", forIndexPath: indexPath) as FCPublicationsDetailsTVTitleCell
            cell.delegate = self
            cell.publication = self.publication?
            return cell
        }
        else if indexPath.row == 1 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("reportsCell", forIndexPath: indexPath) as FCPublicationDetailsTVReportsCell
            cell.publication = self.publication?
            return cell
            
        }
        else if indexPath.row == 2 {
            var cell = self.tableView.dequeueReusableCellWithIdentifier("FCPublicationDetailsDatesCell", forIndexPath: indexPath) as FCPublicationDetailsDatesCell
            cell.publication = self.publication
            return cell
        }
        else if indexPath.row == 3 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationDetailsPhotoCell", forIndexPath: indexPath) as FCPublicationDetailsPhotoCell
            cell.publication = self.publication?
            return cell
        }
        else {
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "stamCell") as UITableViewCell
            return cell
            
        }
    }
    
    func fetchPublicationPhoto() {
        if let publication = self.publication? {
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }

}
