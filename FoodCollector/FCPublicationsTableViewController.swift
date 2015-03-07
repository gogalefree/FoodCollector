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


class FCPublicationsTableViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    weak var delegate: FCPublicationsTVCDelegate!
    var publications = [FCPublication]()
    var filteredPublicaitons = [FCPublication]()
    var searchBar: UISearchBar!
    var isFiltered = false
    let messageViewHidenY: CGFloat = -10
    let messageViewVisibleY: CGFloat = 62
    let messageView = FCPublicationsTVCMessageView.loadFromNibNamed("FCPublicationsTVCMessageView", bundle: nil) as FCPublicationsTVCMessageView
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.publications = FCModel.sharedInstance.publications
        self.publications = FCPublicationsSorter.sortPublicationsByDistanceFromUser(self.publications)
        addSearchBar()
        self.tableView.contentOffset.y = CGRectGetHeight(self.searchBar.bounds)
        self.registerForNotifications()
    }
    
    //MARK: - UISearchBar
    func addSearchBar() {
    
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44))
        self.searchBar = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = UISearchBarStyle.Prominent
        searchBar.scopeButtonTitles = ["Closest" , "Recent" , "Available"]
        searchBar.showsScopeBar = true
        searchBar.selectedScopeButtonIndex = 0
        searchBar.sizeToFit()
        
        let white = UIColor.whiteColor()
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(white, view: self.view), forState: .Normal)
        
        let color = UIColor(red: 245, green: 221, blue: 249, alpha: 0.5)
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(color, view: self.view), forState: .Selected)
        searchBar.scopeBarBackgroundImage = UIImage.imageWithColor(white, view: self.view)
        self.tableView.tableHeaderView = searchBar
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
    
    func searchPublications(text: String) -> [FCPublication] {
        
        var filtered = [FCPublication]()
        
        for publication in self.publications {
        
            var titleRange: Range<String.Index> = Range<String.Index>(start: publication.title.startIndex  ,end: publication.title.endIndex)
            
            var titleFound = publication.title.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: titleRange, locale: nil)
        
           
            var subtitleFound: Range<String.Index>?
            
            if let subtitle = publication.subtitle {
                
               var subTitleRange = Range<String.Index>(start: subtitle.startIndex  ,end: subtitle.endIndex)
               
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCellWithIdentifier("publicationTableViewCell", forIndexPath: indexPath) as FCPublicationsTVCell

        var publication: FCPublication
        
        if self.isFiltered {
            publication = self.filteredPublicaitons[indexPath.row] as FCPublication
        }
        else {
            publication = self.publications[indexPath.row] as FCPublication
        }
        cell.publication = publication
        FCTableViewAnimator.animateCell(cell, sender: self)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var publication: FCPublication
        
        if self.isFiltered {
            publication = self.filteredPublicaitons[indexPath.row] as FCPublication
        }
        else {
            publication = self.publications[indexPath.row] as FCPublication
        }
        
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        publicationDetailsTVC?.title = title
        publicationDetailsTVC?.publication = publication
        
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזור", style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
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
        self.displayMessageView(recivedPublication, state: .NewPublicationMessage)
       
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(4 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            self.addNewRecivedPublication(recivedPublication)
        })
    }

    func didDeletePublication(notification: NSNotification) {
        
        let publicationIdentifier = FCUserNotificationHandler.sharedInstance.recivedtoDelete.last
        
        if let identifier = publicationIdentifier {
        
            for (index, publication) in enumerate(self.publications) {
                
                if identifier.uniqueId == publication.uniqueId && identifier.version == publication.version {
                    
                    self.displayMessageView(publication, state: .DeleteMessage)
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                        Int64(4 * Double(NSEC_PER_SEC)))
                  
                    dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                        self.removePublicationAtIndex(index)
                    })
                    break
                }
            }
        }
    }
    
    func displayMessageView(publication: FCPublication, state: FCPublicationTVCMessageViewState)  {
    
        self.messageView.frame = CGRectMake(0, self.messageViewHidenY , self.view.bounds.width, 66)
        self.navigationController?.view.addSubview(self.messageView)
        self.messageView.publication = publication
        self.messageView.state = state
        self.navigationController?.view.addSubview(self.messageView)
        self.messageView.animateToYWithSpring(0.8, Yvalue: self.messageViewVisibleY) { (completion) -> () in}
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.hideMessageView()
            })
        
    }
    
    func hideMessageView() {
        self.messageView.animateToYWithSpring(0.4, Yvalue: self.messageViewHidenY) { (completion) -> () in
            self.messageView.removeFromSuperview()
            self.messageView.reset()

        }
    }
    
    func removePublicationAtIndex(index: Int){
        
        self.tableView.beginUpdates()
        self.publications.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
   
    func addNewRecivedPublication(publication: FCPublication) {
        self.tableView.beginUpdates()
        self.publications.insert(publication, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeletePublication:", name: kDeletedPublicationNotification, object: nil)
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewPublication:", name: kRecievedNewPublicationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
}

