//
//  FCActivityCenterTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let collectorTitle = String.localizedStringWithFormat("בדרך לאסוף", "activity center table view collector section title. means collector")
let publisherTitle = String.localizedStringWithFormat("השיתופים שלי", "activity center table view publisher section title. means contributer")
let backButtonLabel = String.localizedStringWithFormat("חזרה", "The label of a back button")
let collectorIcon = UIImage(named: "CollectActivity")
let publisherIcon = UIImage(named: "DonateActivity")


class FCActivityCenterTVC: UITableViewController , ActivityCenterHeaderViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var leftSwipeGesture: UISwipeGestureRecognizer!

    let kTableviewPortraitInset: CGFloat = 58.0
    let kTableviewLandscapeInset: CGFloat = 10.0

    
    var userRegisteredPublications = FCModel.sharedInstance.userRegisteredPublications()
    var userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
    var isPresenteingregisteredPublication  = false
    var isPresentingUserCreatedPublications = false
    
    let navBarColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
    
    var selectedIndexPath: NSIndexPath!


    final override func viewDidLoad() {
        
        super.viewDidLoad()

        leftSwipeGesture.addTarget(self, action: "leftSwipeAction:")
        self.navigationController?.navigationBar.barTintColor = navBarColor
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeleteOldVersionOfUserCreatedPublication", name: kDidDeleteOldVersionsOfUserCreatedPublication, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecievePublicationRegistration:", name: kRecievedPublicationRegistrationNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.height > view.frame.width {
            self.tableView.contentInset.top = kTableviewPortraitInset
        }
    }
    
    final override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        if size.height > size.width {
            
            self.tableView.contentInset.top = kTableviewLandscapeInset

        }
        else if size.width > size.height {

            self.tableView.contentInset.top = kTableviewPortraitInset
        }
    }
    
    final func leftSwipeAction(recognizer: UISwipeGestureRecognizer) {
        
        let container = self.navigationController?.parentViewController as! FCCollectorContainerController
        container.collectorVCWillSlide()
    }
        
    final func displaySections() {
        
        if !self.isPresenteingregisteredPublication{
            self.headerTapped(0)
        }
        if !self.isPresentingUserCreatedPublications{
            self.headerTapped(1)
        }
    }
    
    final func reload() {
        
        self.userRegisteredPublications = FCModel.sharedInstance.userRegisteredPublications()
        self.userCreatedPublications = FCModel.sharedInstance.userCreatedPublications.filter {(publication: FCPublication) in
            return publication.isOnAir == true && publication.endingDate.timeIntervalSince1970 > NSDate().timeIntervalSince1970}
        self.tableView.reloadData()
    }
    
    final func removeExpiredUserCreatedPublications() {
        
        let removeExpiredUserCreatedPublicationOperation = NSBlockOperation { () -> Void in
                       
            var indexesToRemove = [Int]()
            
            for (index ,userCreatedPublication) in enumerate(self.userCreatedPublications){
                
                if !userCreatedPublication.isOnAir || FCDateFunctions.PublicationDidExpired(userCreatedPublication.endingDate){
                    indexesToRemove.append(index)
                }
            }
            
            for (index, indexToRemove) in enumerate(indexesToRemove) {
                let removalIndex = indexToRemove - index
                self.userCreatedPublications.removeAtIndex(removalIndex)
            }
            
        }
        
        removeExpiredUserCreatedPublicationOperation.completionBlock = {
            
            //self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            self.tableView.reloadData()
        }
        
        let removeQue = NSOperationQueue.mainQueue()
        removeQue.qualityOfService = .UserInteractive
        removeQue.addOperations([removeExpiredUserCreatedPublicationOperation], waitUntilFinished: false)
    }

    // MARK: - Table view data source

    final override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    final override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case 0:
            if !isPresenteingregisteredPublication { return 0 }
            return self.userRegisteredPublications.count
        case 1:
            if !isPresentingUserCreatedPublications { return 0 }
            return self.userCreatedPublications.count
        default: return 0
        }
    }
    
    final override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
   final override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = FCActivityCenterTVCSectionHeader.loadFromNibNamed("FCActivityCenterTVSectionHeader")as! FCActivityCenterTVCSectionHeader
        headerView.section = section
        headerView.delegate = self
        return headerView
    }

    final override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }

    final override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("FCActivityCenterTVCell", forIndexPath: indexPath) as! FCActivityCenterTVCell
        
        let publication = self.publicationForIndexPath(indexPath)
        cell.publication = publication
        return cell
    }

    final override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var publication = self.publicationForIndexPath(indexPath)
        let title = titleForIndexPath(indexPath)
        
        switch indexPath.section {
        case 0:
            let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
            publicationDetailsTVC?.setupWithState(PublicationDetailsTVCViewState.Collector, caller: PublicationDetailsTVCVReferral.ActivityCenter, publication: publication)
            
            publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButtonLabel, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            
        case 1:
            let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
            publicationDetailsTVC?.setupWithState(PublicationDetailsTVCViewState.Publisher, caller: PublicationDetailsTVCVReferral.ActivityCenter, publication: publication)
            
            publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButtonLabel, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            publicationDetailsTVC?.deleteDelgate = self
            
            let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            

            
            /*
            let publicationEditorTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationEditorTVC") as? FCPublicationEditorTVC
            publicationEditorTVC?.setupWithState(.ActivityCenter, publication: publication)
            publicationEditorTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButtonLabel, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            publicationEditorTVC?.title = title
            let nav = UINavigationController(rootViewController: publicationEditorTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            */
        default: break
        
        }
    }
    
    final func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        self.reload()
    }
    
    final func titleForIndexPath(indexPath:NSIndexPath) -> String{
        if indexPath.section == 0 {return collectorTitle}
        else {return publisherTitle}
    }

    final func publicationForIndexPath(indexPath: NSIndexPath)-> FCPublication {
        
        var publication: FCPublication!
        switch indexPath.section {
        case 0:
            publication = self.userRegisteredPublications[indexPath.row]
        case 1:
            publication = self.userCreatedPublications[indexPath.row]
        default:
            publication = nil
        }
        
        return publication
    }
    
    //MARK: - header views delegate
    
    final func headerTapped(section: Int) {
        
        switch section {
        case 0:
            reloadUserRegisteredPublications()
        case 1:
            reloadUserCreayedPublications()
        default:
            break
        }
    }
    
    final func reloadUserRegisteredPublications() {
        
        if !isPresenteingregisteredPublication {
            isPresenteingregisteredPublication = true
        }
        else { isPresenteingregisteredPublication = false }
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    final func reloadUserCreayedPublications() {

        if !isPresentingUserCreatedPublications {
            isPresentingUserCreatedPublications = true
        }
        else { isPresentingUserCreatedPublications = false }
        
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
    }
    
    final func didDeleteOldVersionOfUserCreatedPublication() {
        self.reload()
    }
    
    final func didRecievePublicationRegistration(notification: NSNotification) {
     
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension FCActivityCenterTVC: UserDidDeletePublicationProtocol {
    func didDeletePublication(publication: FCPublication,  collectionViewIndex: Int) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            self.reload()
        })
    }
    
    func didTakeOffAirPublication(publication: FCPublication) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            
            //update model
            publication.isOnAir = false
            FCModel.sharedInstance.saveUserCreatedPublications()
            
            //inform server and model
            FCModel.sharedInstance.foodCollectorWebServer.takePublicationOffAir(publication, completion: { (success) -> Void in
                
                if success{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //self.navigationController?.popViewControllerAnimated(true)
                        let publicationIdentifier = PublicationIdentifier(uniqueId: publication.uniqueId, version: publication.version)
                        FCUserNotificationHandler.sharedInstance.recivedtoDelete.append(publicationIdentifier)
                        FCModel.sharedInstance.deletePublication(publicationIdentifier, deleteFromServer: false, deleteUserCreatedPublication: false)
                    })
                }
                else{
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not take your event off air", aMessage: "try again later")
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                }
            })

            self.reload()
        })
    }
}
