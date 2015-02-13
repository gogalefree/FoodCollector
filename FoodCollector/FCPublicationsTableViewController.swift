//
//  FCPublicationsTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import UIKit
import Foundation


protocol FCPublicationsTVCDelegate {
    func didChosePublication(publication:FCPublication)
}


/// presents all Publication in a tableView.
/// must be sorted by distance from user location. nearest is first.


class FCPublicationsTableViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var publications = [FCPublication]()
    var filteredPublicaitons = [FCPublication]()
    var searchBar: UISearchBar!
    var isFiltered = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.publications = FCModel.sharedInstance.publications
        self.publications = FCPublicationsSorter.sortPublicationsByDistanceFromUser(self.publications)
        addSearchBar()
        self.tableView.contentOffset.y = CGRectGetHeight(self.searchBar.bounds)

        
//        let sortedByCount = FCPublicationsSorter.sortPublicationsByCountOfRegisteredUsers(self.publications)
//        let  sortedByStartingDate = FCPublicationsSorter.sortPublicationsByStartingDate(self.publications)
//        
//        for publication in sortedByCount {
//            println("\(publication.title) count \(publication.countOfRegisteredUsers)")
//        }
//        
//        for publication in sortedByStartingDate {
//            println("\(publication.title) count \(publication.startingDate)")
//        }
//        
    }
    
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
        searchBar.setScopeBarButtonBackgroundImage(imageWithColor(white), forState: .Normal)
        
        let color = UIColor(red: 245, green: 221, blue: 249, alpha: 0.5)
        searchBar.setScopeBarButtonBackgroundImage(imageWithColor(color), forState: .Selected)
        searchBar.scopeBarBackgroundImage = imageWithColor(white)
        self.tableView.tableHeaderView = searchBar
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        var rect = CGRectMake(0, 0, self.view.bounds.width, 40)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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

    
}

