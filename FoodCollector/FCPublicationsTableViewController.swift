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
/// must be sorted by distance from user location. nearest is first.

//TODO: chnage to NSFetchResultsController
//TODO: Delete the new message view. we'll present it from the container controller

class FCPublicationsTableViewController : UITableViewController, UISearchBarDelegate {
    
    weak var delegate: FCPublicationsTVCDelegate!
    var publications = [Publication]()
    var filteredPublicaitons = [Publication]()
    var searchBar: UISearchBar!
    var isFiltered = false
    
    let navBarTitle = NSLocalizedString("Events Near You", comment:"Nav Bar title - the events near you")
    let navBarSearchPlaceHolderText = NSLocalizedString("Search", comment:"Search bar placeholder text")
    let scopeButtonTitlesClosest = NSLocalizedString("Closest", comment:"Search bar scope button titles")
    let scopeButtonTitlesRecent = NSLocalizedString("Recent", comment:"Search bar scope button titles")
    let scopeButtonTitlesActive = NSLocalizedString("Active", comment:"Search bar scope button titles")
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = navBarTitle
        self.publications = FCModel.sharedInstance.publications
        self.publications = FCPublicationsSorter.sortPublicationsByDistanceFromUser(self.publications)
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
        switch selectedScope {
        case 0:
            //sort by distance
            self.publications = FCPublicationsSorter.sortPublicationsByDistanceFromUser(self.publications)
            self.filteredPublicaitons = FCPublicationsSorter.sortPublicationsByDistanceFromUser(self.publications)
        case 1:
            //sort by StartingDate
            self.publications = FCPublicationsSorter.sortPublicationsByStartingDate(self.publications)
            self.filteredPublicaitons = FCPublicationsSorter.sortPublicationsByStartingDate(self.publications)
            
        case 2:
            //sort by count of registered uaers
            self.publications = FCPublicationsSorter.sortPublicationsByCountOfRegisteredUsers(self.publications)
            self.filteredPublicaitons = FCPublicationsSorter.sortPublicationsByCountOfRegisteredUsers(self.publications)
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {

        self.searchBar.resignFirstResponder()
    }
    
    func searchPublications(text: String) -> [Publication] {
        
        var filtered = [Publication]()
        
        for publication in self.publications {
        
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
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltered {return self.filteredPublicaitons.count}
        return self.publications.count
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 96
//    }
//    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCellWithIdentifier("publicationTableViewCell", forIndexPath: indexPath)as! FCPublicationsTVCell

        var publication: Publication
        
        if self.isFiltered {
            publication = self.filteredPublicaitons[indexPath.row]
        }
        else {
            publication = self.publications[indexPath.row]
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
            publication = self.publications[indexPath.row]
        }
        
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        publicationDetailsTVC?.title = publication.title
        publicationDetailsTVC?.publication = publication
        
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
        let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
        
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
    
    func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showActivityCenter(sender: UIButton) {
    
        if let delegate = self.delegate {
            delegate.didRequestActivityCenter()
        }
    }
    
    func didRecieveNewPublication(notification: NSNotification) {
        
        let recivedPublication = FCModel.sharedInstance.publications.last!
        let existingIndex = self.publications.indexOf(recivedPublication)
        
        if existingIndex == nil {
            
            self.addNewRecivedPublication(recivedPublication)
        }
    }

    func didDeletePublication(notification: NSNotification) {
        
        let deleted = FCModel.sharedInstance.userDeletedPublication
        if let publication = deleted {
            
            let index = self.publications.indexOf(publication)
            if let foundIndex = index {
                
                let indexpath = NSIndexPath(forRow: foundIndex, inSection: 0)
                self.tableView.beginUpdates()
                self.publications.removeAtIndex(foundIndex)
                self.tableView.deleteRowsAtIndexPaths([indexpath], withRowAnimation: .Fade)
                self.tableView.endUpdates()
            }
        }
    }
    
    func addNewRecivedPublication(publication: Publication) {
        self.tableView.beginUpdates()
        self.publications.insert(publication, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    func registerForAppNotifications() {
   
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewPublication:", name: kRecievedNewPublicationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
}

