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
let collectorIcon = UIImage(named: "CollectWhite")
let publisherIcon = UIImage(named: "DonateWhite")


class FCActivityCenterTVC: UITableViewController , ActivityCenterHeaderViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var leftSwipeGesture: UISwipeGestureRecognizer!

    var userRegisteredPublications = FCModel.sharedInstance.userRegisteredPublications()
    var userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
    
    var isPresenteingregisteredPublication  = false
    var isPresentingUserCreatedPublications = false
    
    var selectedIndexPath: NSIndexPath!


    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 55
        self.tableView.rowHeight = UITableViewAutomaticDimension
        reload()
        leftSwipeGesture.addTarget(self, action: "leftSwipeAction:")
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
    }
    
    func leftSwipeAction(recognizer: UISwipeGestureRecognizer) {
        
        let container = self.navigationController?.parentViewController as! FCCollectorContainerController
        container.collectorVCWillSlide()
    }
        
    func displaySections() {
        
        if !self.isPresenteingregisteredPublication{
            self.headerTapped(0)
        }
        if !self.isPresentingUserCreatedPublications{
            self.headerTapped(1)
        }
    }
    
    func reload() {
        
        self.userRegisteredPublications = FCModel.sharedInstance.userRegisteredPublications()
        self.userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
        self.removeExpiredUserCreatedPublications()
        self.tableView.reloadData()
    }
    
    func removeExpiredUserCreatedPublications() {
        
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = FCActivityCenterTVCSectionHeader.loadFromNibNamed("FCActivityCenterTVSectionHeader")as! FCActivityCenterTVCSectionHeader
        headerView.section = section
        headerView.delegate = self
        return headerView
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("FCActivityCenterTVCell", forIndexPath: indexPath) as! FCActivityCenterTVCell
        
        let publication = self.publicationForIndexPath(indexPath)
        cell.publication = publication
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var publication = self.publicationForIndexPath(indexPath)
        let title = titleForIndexPath(indexPath)
        
        switch indexPath.section {
        case 0:
            let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
            publicationDetailsTVC?.title = title
            publicationDetailsTVC?.publication = publication
            
            publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזור", style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            
        case 1:
            let publicationEditorTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationEditorTVC") as? FCPublicationEditorTVC
            publicationEditorTVC?.setupWithState(.ActivityCenter, publication: publication)
            publicationEditorTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזור", style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            publicationEditorTVC?.title = title
            let nav = UINavigationController(rootViewController: publicationEditorTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        
        default: break
        
        }
    }
    
    func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        self.reload()
    }
    
    func titleForIndexPath(indexPath:NSIndexPath) -> String{
        if indexPath.section == 0 {return collectorTitle}
        else {return publisherTitle}
    }

    func publicationForIndexPath(indexPath: NSIndexPath)-> FCPublication {
        
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
    
    func headerTapped(section: Int) {
        
        switch section {
        case 0:
            reloadUserRegisteredPublications()
        case 1:
            reloadUserCreayedPublications()
        default:
            break
        }
    }
    
    func reloadUserRegisteredPublications() {
        
        if !isPresenteingregisteredPublication {
            isPresenteingregisteredPublication = true
        }
        else { isPresenteingregisteredPublication = false }
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
    
    func reloadUserCreayedPublications() {

        if !isPresentingUserCreatedPublications {
            isPresentingUserCreatedPublications = true
        }
        else { isPresentingUserCreatedPublications = false }
        
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
