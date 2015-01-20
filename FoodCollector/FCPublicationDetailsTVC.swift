//
//  FCPublicationDetailsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationDetailsTVC: UITableViewController, FCPublicationDetailsTitleCellDelegate {
    
    var publication: FCPublication?
    // var didFetchPublicationReports = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 116
        self.tableView.rowHeight = UITableViewAutomaticDimension
        fetchPublicationReports()
        fetchPublicationPhoto()
     
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
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
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
