//
//  ActivityLogTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 03/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class ActivityLogTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var _fetchedResultsController :NSFetchedResultsController?
    
    var fetchedResultsController: NSFetchedResultsController {
    
        if _fetchedResultsController != nil {return _fetchedResultsController!}
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: "ActivityLog")
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false) , NSSortDescriptor(key: "isNew", ascending: true)]
        
        let aFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        aFetchResultsController.delegate =  self
        _fetchedResultsController = aFetchResultsController
        
        do {
            try _fetchedResultsController!.performFetch()

        } catch {
            print("error fetching activity logs by fetchedResultsController \(error) ")
        }
        
        return _fetchedResultsController!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        backButton.setBackgroundImage(FCIconFactory.backBGImage(), forState: .Normal, barMetrics: .Default)
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.estimatedRowHeight  = 80
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        FCUserNotificationHandler.sharedInstance.notificationsBadgeCounter = 0
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        FCModel.sharedInstance.dataController.save()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![0].numberOfObjects
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("activityLogCell", forIndexPath: indexPath) as! ActivityLogTVCell
        let log = self.fetchedResultsController.objectAtIndexPath(indexPath) as? ActivityLog
        cell.log = log
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let activityLog = fetchedResultsController.objectAtIndexPath(indexPath) as? ActivityLog
        guard let log = activityLog else {return}
        let logType = log.type?.integerValue ?? 0
        guard let type = ActivityLog.LogType(rawValue:logType) else {return}
        
        switch type {
            
            //present Groups VC
        case .NewGroup:
           
            if !User.sharedInstance.userIsLoggedIn {
                presentLogin()
                return
            }
            
            let groupsStoryBoard = UIStoryboard(name: "Groups", bundle: nil)
            let groupsNavVC = groupsStoryBoard.instantiateInitialViewController() as? UINavigationController
            self.presentViewController(groupsNavVC!, animated: true, completion: nil)
            

        case .DeletePublication:
            
            presentPublicationEndedMessage()
            
        default:
            //present publication details
            presentPublicationDetailsForLog(log)
            
        }
        
    }
    
    func presentPublicationDetailsForLog(log: ActivityLog) {
        
        let publicationID = log.objectId?.integerValue ?? 0
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: kPublicationEntity)
        request.predicate = NSPredicate(format: "uniqueId = %@", NSNumber(integer: publicationID))
        do {
         
            let results = try moc.executeFetchRequest(request) as? [Publication]
            guard let publications = results else {return}
            guard let publication = publications.first else {
            
                presentPublicationEndedMessage()
                return
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let publicationDetailsTVC = storyBoard.instantiateViewControllerWithIdentifier("PublicationDetailsVC") as? PublicationDetailsVC
            publicationDetailsTVC?.publication = publication
            
            let state: PublicationDetailsTVCViewState = publication.isUserCreatedPublication!.boolValue ? .Publisher : .Collector
            publicationDetailsTVC?.state = state
            
            let barButton = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.dismissDetailVC))
            barButton.setBackgroundImage(FCIconFactory.backBGImage(), forState: .Normal, barMetrics: .Default)
            publicationDetailsTVC?.navigationItem.leftBarButtonItem = barButton
            let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        } catch let error as NSError {
            print("error fetching publication in activity log vc: \(error.description) \(#function)")
        }
    }
    
    func presentPublicationEndedMessage(){
        
        let title = NSLocalizedString("This event has ended", comment: "alert title")
        let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(title, aMessage: "")
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissDetailVC() {
    
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentLogin() {
        
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginRootVCNavController = loginStoryboard.instantiateViewControllerWithIdentifier("IdentityProviderLoginNavVC") as! UINavigationController
        self.presentViewController(loginRootVCNavController, animated: true, completion: nil)
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.beginUpdates()
    }
    
    //we dont need this as long as we have one section
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
            
        case .Delete:
            if controller.sections![0].numberOfObjects == 0 {
                tableView.reloadData()
                tableView.setEditing(false, animated: true)
            } else {
                
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }

        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!] ,withRowAnimation:.Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return fetchedResultsController.sections![0].numberOfObjects > 0
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if fetchedResultsController.sections![0].numberOfObjects == 0 {
            super.setEditing(false, animated: false)
        }
        else {
            super.setEditing(editing, animated: animated)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            let logTODelete = fetchedResultsController.objectAtIndexPath(indexPath) as! ActivityLog
            let moc = FCModel.sharedInstance.dataController.managedObjectContext
            moc.deleteObject(logTODelete)
            FCModel.sharedInstance.dataController.save()
        }
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
