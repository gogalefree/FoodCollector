//
//  FCPublicationsTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import UIKit
import Foundation


protocol FCPublicationsTVCDelegate: NSObjectProtocol{
    func didRequestActivityCenter()
}


/// presents all Publication in a tableView.
/// initially sorted by distance from user location. nearest is first.

//for notifications badge number, use: NSUsernotificationsHandler.sharedInstance.notificationsBadgeCounter

class FCPublicationsTableViewController : UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    weak var delegate: FCPublicationsTVCDelegate!
    var filteredPublicaitons = [Publication]()
    var searchBar: UISearchBar!
    var isFiltered = false
    
    let navBarTitle = NSLocalizedString("Events Near You", comment:"Nav Bar title - the events near you")
    let navBarSearchPlaceHolderText = NSLocalizedString("Search", comment:"Search bar placeholder text")
    let scopeButtonTitlesClosest = NSLocalizedString("Closest", comment:"Search bar scope button titles")
    let scopeButtonTitlesRecent = NSLocalizedString("Recent", comment:"Search bar scope button titles")
    let scopeButtonTitlesActive = NSLocalizedString("Active", comment:"Search bar scope button titles")
    
    var _fetchedResultsController :NSFetchedResultsController?
    
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {return _fetchedResultsController!}
        
        let moc = FCModel.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: kPublicationEntity)
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "storedDistanceFromUserLocation", ascending: true)]
        
        let predicate = NSPredicate(format: "startingData < %@ && endingData > %@ && isOnAir = %@", NSDate(), NSDate() , NSNumber(bool: true) )
        request.predicate = predicate
        
        let aFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        aFetchResultsController.delegate =  self
        _fetchedResultsController = aFetchResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
            
        } catch {
            print("error fetching activity logs by fetchedResultsController \(error) " + __FUNCTION__)
        }
        
        return _fetchedResultsController!
    }
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = navBarTitle
        addSearchBar()
        self.tableView.estimatedRowHeight = 96
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentOffset.y = CGRectGetHeight(self.searchBar.bounds)
        self.registerForAppNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAController.reportsAnalyticsForScreen(kFAPublicationsTVCScreenName)
    }
    
    //MARK: - UISearchBar
    func addSearchBar() {
        
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44))
        self.searchBar = searchBar
        searchBar.delegate = self
        searchBar.placeholder = navBarSearchPlaceHolderText
        searchBar.searchBarStyle = UISearchBarStyle.Prominent
        searchBar.scopeButtonTitles = [scopeButtonTitlesClosest, scopeButtonTitlesRecent, scopeButtonTitlesActive]
        searchBar.showsScopeBar = true
        searchBar.selectedScopeButtonIndex = 0
        searchBar.sizeToFit()
        
        //print("SUBVIEWS Count: \(searchBar.subviews[0].subviews[0].subviews.count)")
        //print("SUBVIEWS 0: \(searchBar.subviews[0].subviews[0].subviews[0].description)")
        //print("SUBVIEWS 1: \(searchBar.subviews[0].subviews[0].subviews[1].description)")
        
        let white = UIColor.whiteColor()
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(white, view: self.view), forState: .Normal)
        
        let color = UIColor(red: 245, green: 221, blue: 249, alpha: 0.5)
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(color, view: self.view), forState: .Selected)
        searchBar.scopeBarBackgroundImage = UIImage.imageWithColor(white, view: self.view)
        self.tableView.tableHeaderView = searchBar
    }
    
    func findCancelButonInSearchBar(currentView: UIView){
        // Get the subviews of the searchBar
        let viewsArray = currentView.subviews
        
        // Return if there are no subviews
        if (viewsArray.count == 0) {
            return
        }
        
        for subView in viewsArray {
            if subView.isKindOfClass(UIButton) {
                if (subView as! UIButton).currentTitle != nil {
                    (subView as! UIButton).setTitle(kCancelButtonTitle, forState: .Normal)
                    return
                }
            }
            
            // Resursive call
            self.findCancelButonInSearchBar(subView );
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            
            self.isFiltered = false
        }
        else {
        
            self.isFiltered = true
            self.filteredPublicaitons = searchPublications(searchText)
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        findCancelButonInSearchBar(searchBar)
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.isFiltered = false
        self.searchBar.resignFirstResponder()
        self.tableView.reloadData()
        self.searchBar.text = ""
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
      
        var sorter = NSSortDescriptor()
        isFiltered = false
        //let publications = self.fetchedResultsController.fetchedObjects as! [Publication]

        switch selectedScope {
            
            
        case 0:
            //sort by distance
            sorter = NSSortDescriptor(key: "storedDistanceFromUserLocation", ascending: true)
        case 1:
            //sort by StartingDate
            sorter = NSSortDescriptor(key: "startingData", ascending: true)
            
        case 2:
            //sort by count of registered users
            isFiltered = true
            let publications = fetchedResultsController.fetchedObjects as! [Publication]
            self.filteredPublicaitons = publications.sort {(publicationA, publicationB) in publicationA.registrations?.count < publicationB.registrations?.count}
            self.tableView.reloadData()
            return
            
        default:
            break
        }
        
        fetchedResultsController.fetchRequest.sortDescriptors = [sorter]
        do {
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch {
            print("error refetching in publications table view \(error)")
        }
        
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {

        self.searchBar.resignFirstResponder()
    }
    
    func searchPublications(text: String) -> [Publication] {
        
        var filtered = [Publication]()
        
        let publications = self.fetchedResultsController.fetchedObjects as! [Publication]
        
        for publication in publications {
        
            let titleRange: Range<String.Index> = Range<String.Index>(start: publication.title!.startIndex  ,end: publication.title!.endIndex)
            
            let titleFound = publication.title!.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: titleRange, locale: nil)
        
           
            var subtitleFound: Range<String.Index>?
            
            if let subtitle = publication.subtitle {
                
               let subTitleRange = Range<String.Index>(start: subtitle.startIndex  ,end: subtitle.endIndex)
               
                subtitleFound = subtitle.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: subTitleRange, locale: nil)
    
            }
           
            if titleFound != nil || subtitleFound != nil {
                filtered.append(publication)
            }
        }
        
        return filtered
    }
    
    //MARK: - Table view Delegate DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltered {return self.filteredPublicaitons.count}
        return fetchedResultsController.sections![0].numberOfObjects
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCellWithIdentifier("publicationTableViewCell", forIndexPath: indexPath)as! FCPublicationsTVCell

        var publication: Publication
        
        if self.isFiltered {
            publication = self.filteredPublicaitons[indexPath.row]
        }
        else {
            publication = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Publication
        }
        cell.publication = publication
        FCTableViewAnimator.animateCell(cell, sender: self)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var publication: Publication
        
        if self.isFiltered {
            publication = self.filteredPublicaitons[indexPath.row] 
        }
        else {
            publication = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Publication
        }
        
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        publicationDetailsTVC?.title = publication.title
        publicationDetailsTVC?.publication = publication
        
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
        let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
        
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
    
    //MARK: INSERT & DELETE animations
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            if controller.sections![0].numberOfObjects == 1 {tableView.reloadData()} else {
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
            
        case .Delete:
            if controller.sections![0].numberOfObjects == 0 {
                tableView.reloadData()
                tableView.setEditing(false, animated: true)
            } else {
                
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
            
            //we dont allow move for now
            //        case .Move:
            //            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            //            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            break
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showActivityCenter(sender: UIButton) {
    
        if let delegate = self.delegate {
            delegate.didRequestActivityCenter()
        }
    }
    
    
    //BORIS
    //this is called when the notifications icon needs update
    func updateNotificationBadgeCounter() {
        
        let newNotificationsCount = FCUserNotificationHandler.sharedInstance.notificationsBadgeCounter
    }
    
    //DEPARECATED v1.0.9
//    func didRecieveNewPublication(notification: NSNotification) {
//        
//        let recivedPublication = FCModel.sharedInstance.publications.last!
//        let existingIndex = self.publications.indexOf(recivedPublication)
//        
//        if existingIndex == nil {
//            
//            self.addNewRecivedPublication(recivedPublication)
//        }
//    }

//    func didDeletePublication(notification: NSNotification) {
//        
//        let deleted = FCModel.sharedInstance.userDeletedPublication
//        if let publication = deleted {
//            
//            let index = self.publications.indexOf(publication)
//            if let foundIndex = index {
//                
//                let indexpath = NSIndexPath(forRow: foundIndex, inSection: 0)
//                self.tableView.beginUpdates()
//                self.publications.removeAtIndex(foundIndex)
//                self.tableView.deleteRowsAtIndexPaths([indexpath], withRowAnimation: .Fade)
//                self.tableView.endUpdates()
//            }
//        }
//    }
    
//    func addNewRecivedPublication(publication: Publication) {
//        self.tableView.beginUpdates()
//        self.publications.insert(publication, atIndex: 0)
//        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
//        self.tableView.endUpdates()
//    }
    
    func registerForAppNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationBadgeCounter", name: kUpdateNotificationsCounterNotification, object: nil)
        
        //DEPRECATED v1.0.9
        //we use NSFetchedResultesController so updates are performed automatically
//   
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewPublication:", name: kRecievedNewPublicationNotification, object: nil)
    }
    
//END OF DEPRECATION v1.0.9
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
}

