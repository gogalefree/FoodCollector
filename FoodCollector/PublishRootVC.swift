//
//  PublishRootVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 29.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

///
/// show all user created publication: live and expired.
/// contains a button for creating a new Publication.
/// clicking an item starts’ editing mode of that item.
///

class PublishRootVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    let searchBarPlaceHolderText = NSLocalizedString("Search", comment:"Search bar placeholder text")
    let scopeButtonTitlesOnAir = NSLocalizedString("On Air", comment:"Search bar scope button titles")
    let scopeButtonTitlesOffAir = NSLocalizedString("Off Air", comment:"Search bar scope button titles")
    let scopeButtonTitlesEnds = NSLocalizedString("Ends", comment:"Search bar scope button titles")


    @IBOutlet weak var publicationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var noUserCreatedPublicationMessageLabel: UILabel?
    var noUserCreatedPublicationMessageText = NSLocalizedString("Hi,(br)What would you like to share?" , comment:"No user created publications message. DO NOT change or delete (br) !!!")
    
    var filteredUserCreatedPublications = [Publication]()
    var publicationsTableViewHidden = false
    
    var searchTextCharCount = 0
    var onceToken = 0
    var isFiltered = false
    var unPresentedPublications = [Publication]()
    
    var _fetchedResultsController :NSFetchedResultsController?
    
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {return _fetchedResultsController!}
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let request = NSFetchRequest(entityName: kPublicationEntity)
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "endingData", ascending: false)]
        
        let predicate = NSPredicate(format: "isUserCreatedPublication = %@" , NSNumber(bool: true) )
        request.predicate = predicate
        
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
        
        searchBarSetup()
        
        publicationsTableView.delegate = self
        publicationsTableView.dataSource = self
        if fetchedResultsController.sections![0].numberOfObjects == 0 {
            
            hideTableView()
        }
        else {

            publicationsTableView.userInteractionEnabled = true
            publicationsTableView.scrollEnabled = true
        }
        
        addCreatePublicationButton()
    }
    
    func searchBarSetup() {
        let white = UIColor.whiteColor()
        let selectedColor = UIColor(red: 245, green: 221, blue: 249, alpha: 0.5)
        
        searchBar.placeholder = searchBarPlaceHolderText
        searchBar.searchBarStyle = UISearchBarStyle.Prominent
        searchBar.scopeButtonTitles = [scopeButtonTitlesOnAir, scopeButtonTitlesOffAir, scopeButtonTitlesEnds]
        searchBar.showsScopeBar = true
        searchBar.selectedScopeButtonIndex = 0
        searchBar.sizeToFit()
        
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(white, view: searchBar), forState: .Normal)
        
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(selectedColor, view: searchBar), forState: .Selected)
        
        searchBar.scopeBarBackgroundImage = UIImage.imageWithColor(white, view: searchBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.publicationsTableView.reloadData()
        if fetchedResultsController.fetchedObjects?.count > 0 {
            showTableView()
        } else {
            hideTableView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        dispatch_once(&onceToken) {
            self.publicationsTableView.contentOffset.y = -64 //assign 0 if you want the search bar to show on load
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAController.reportsAnalyticsForScreen(kFAPublisherRootVCScreenName)
    }
        
    // MARK: - Table View Functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //If you keep the search bar as a cell, you need to return the count + 1
        
        if isFiltered {return filteredUserCreatedPublications.count}
        
        let count = fetchedResultsController.sections![0].numberOfObjects
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //it's better to have the search bar as a seperate viwe and assign it as the tableViewHeaderView, and not as a cell.
        
//        if indexPath.row == 0 {
//            let reusableId = "PublishTableViewSearchCell"
//            let cell = tableView.dequeueReusableCellWithIdentifier(reusableId, forIndexPath: indexPath) as! PublishRootVCCustomTableViewSearchCell
//            return cell
//        }
//        
        
        var publication: Publication
        
        if isFiltered {
            publication = filteredUserCreatedPublications[indexPath.row]
        }
        else {
            publication = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Publication
            
        }
        
        let reusableId = "PublishTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableId, forIndexPath: indexPath) as! PublishRootVCCustomTableViewCell
        cell.publication = publication
        
        // The tag property will be used later in the segue to identify
        // the publication item clicked by the user for editing.
        // Why don't you pass the indexPath itself?
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // This will crash since the first cell is the SearchCell
        // It's better to remove the search bar out of the table view and keep it as a seperate view
        var publication: Publication
        
        if isFiltered {
            publication = filteredUserCreatedPublications[indexPath.item]
        }
        else {
            publication = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Publication
            
        }
        
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublicationDetailsVC") as? PublicationDetailsVC
        
        publicationDetailsTVC?.setupWithState(PublicationDetailsTVCViewState.Publisher, caller: PublicationDetailsTVCVReferral.MyPublications, publication: publication, publicationIndexPath: indexPath.item)
        
        let barButton = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(PublishRootVC.dismissDetailVC))
        barButton.setBackgroundImage(FCIconFactory.backBGImage(), forState: .Normal, barMetrics: .Default)
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = barButton
        
        publicationDetailsTVC?.deleteDelgate = self
        
        let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showNewPublicationEditorTVC") {
            // If the user is logged in: let him create a new publication event.
            // If the user is NOT logged in: start login process.
            
            if User.sharedInstance.userIsLoggedIn {
                let publicationEditorTVC = segue!.destinationViewController as! PublicationEditorTVC
                publicationEditorTVC.setupWithState(.CreateNewPublication, publication: nil)
            }
            else {
                showPickupRegistrationAlert()
            }
            
        }
    }
    
    func addCreatePublicationButton(){
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let buttonWidth = CGFloat(60)
        let buttonHeight = CGFloat(61)
        let spaceFromBottom = CGFloat(35)
        let buttonX = screenWidth / 2
        let buttonY = screenHeight - spaceFromBottom - (buttonHeight / 2)
        
        let image = UIImage(named: "NewPublicationPlusBtn") as UIImage?
        
        let button   = UIButton(type: UIButtonType.Custom)
        button.frame.size = CGSizeMake(buttonWidth,buttonHeight)
        button.center = CGPointMake(buttonX, buttonY)
        //button.layer.cornerRadius = buttonWidth / 2
        
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(PublishRootVC.createNewPublicationButtonTouched(_:)), forControlEvents:.TouchUpInside)
        
        self.view.addSubview(button)
    }
    
    func createNewPublicationButtonTouched(object : UIButton) {
        print("createNewPublicationButtonTouched")
        
        // If the user is logged in: let him create a new publication event.
        // If the user is NOT logged in: start login process.
        
        if User.sharedInstance.userIsLoggedIn {
            if let newShareVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublicationEditorTVC") as? PublicationEditorTVC {
                newShareVC.setupWithState(.CreateNewPublication, publication: nil)
                
                let barButton = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.dismissDetailVC))
                barButton.setBackgroundImage(FCIconFactory.backBGImage(), forState: .Normal, barMetrics: .Default)
                newShareVC.navigationItem.leftBarButtonItem = barButton
                let nav = UINavigationController(rootViewController: newShareVC)
                self.presentViewController(nav, animated: true, completion: nil)
            }
            
            
            //let publicationEditorTVC = segue!.destinationViewController as! PublicationEditorTVC
            //publicationEditorTVC.setupWithState()
        }
        else {
            showPickupRegistrationAlert()
        }
    }

    
    // MARK: - User / Login Functions
    func showPickupRegistrationAlert() {
        let alertController = UIAlertController(title: kAlertLoginTitle, message: kAlertLoginMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add buttons
        alertController.addAction(UIAlertAction(title: kAlertLoginButtonTitle, style: UIAlertActionStyle.Default,handler: { (action) -> Void in
            self.startLoginprocess()
        }))
        alertController.addAction(UIAlertAction(title: kCancelButtonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func startLoginprocess() {
        print("startLoginprocess")
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let identityProviderLogingViewNavVC = loginStoryboard.instantiateViewControllerWithIdentifier("IdentityProviderLoginNavVC") as! UINavigationController
        
        self.presentViewController(identityProviderLogingViewNavVC, animated: true, completion: nil)
    }
    
    func dismissDetailVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func hideTableView() {
        publicationsTableView.alpha = 0
        publicationsTableViewHidden = true
        displayNoPublicatiosMessage()
    }
    
    func showTableView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.publicationsTableViewHidden = false
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.publicationsTableView.alpha = 1
                if let label = self.noUserCreatedPublicationMessageLabel {
                    label.alpha = 0
                }
            })
        }
    }
    
    func displayNoPublicatiosMessage(){
        
        if self.noUserCreatedPublicationMessageLabel == nil {
            let recWidth = DeviceData.screenWidth()/1.4
            let recHight = DeviceData.screenHight()/1.4
            let recCenterX = DeviceData.screenWidth()/2
            let recCenterY = DeviceData.screenHight()/2
            let fontSize = DeviceData.screenWidth()/10 - 9
            
            self.noUserCreatedPublicationMessageLabel = UILabel(frame: CGRectMake(0, 0, recWidth, recHight))
            
            if let label = self.noUserCreatedPublicationMessageLabel {
                
                label.center = CGPointMake(recCenterX, recCenterY - 100)
                label.textAlignment = NSTextAlignment.Center
                label.numberOfLines = 0
                label.font = UIFont.systemFontOfSize(fontSize)
                label.text = noUserCreatedPublicationMessageText.stringByReplacingOccurrencesOfString("(br)", withString: "\n")
                self.view.addSubview(label)
            }
        }
        else {
            self.noUserCreatedPublicationMessageLabel?.alpha = 1
        }
    }
    
    
    //MARK: - UISearchBar
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        
//        var reusableview:UICollectionReusableView!
//        
//        
//        
//        if (kind == UICollectionElementKindSectionHeader) {
//            
//            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kPublisherRootVCHeaderViewReusableId, forIndexPath: indexPath) as! FCPublisherRootVCCollectionViewHeaderCollectionReusableView
//            
//            headerView.setUp()
//            self.searchBar = headerView.searchBar
//            self.searchBar.delegate = self
//            reusableview = headerView
//        }
//        
//        return reusableview
//    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //user is deleting
        //show all publications
        if searchText == "" || searchText.characters.count < self.searchTextCharCount{
            
            self.isFiltered = false
            self.publicationsTableView.reloadData()
        }
            //user is writing
        else {
            
            self.isFiltered = true
            self.searchPublications(searchText)
        }
        
        //save the count to check whether user writing or deleting
        self.searchTextCharCount = searchText.characters.count
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
        self.searchBar.text = ""
        self.publicationsTableView.reloadData()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.publicationsTableView.contentOffset.y = 20
        })
    }
    
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        var sorter = NSSortDescriptor()
        
        switch selectedScope {
            
        case 0:
            //sort by onAire
            sorter = NSSortDescriptor(key: "isOnAir", ascending: false)
        case 1:
            //sort by OffAir
            sorter = NSSortDescriptor(key: "isOnAir", ascending: false)
            
        case 2:
            //sort by endingDate
            sorter = NSSortDescriptor(key: "endingData", ascending: true)
        default:
            break
        }
        fetchedResultsController.fetchRequest.sortDescriptors = [sorter]
        do {
            try fetchedResultsController.performFetch()
            self.publicationsTableView.reloadData()
        } catch {
            print("error refetching in publisher root vc: \(error)")
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar?.resignFirstResponder()
    }
    
    func searchPublications(text: String) {
        
        var filtered = [Publication]()
        
        let publications = self.fetchedResultsController.fetchedObjects as! [Publication]
        
        for publication in publications {
            
            let titleRange: Range<String.Index> = Range<String.Index>(publication.title!.startIndex ..< publication.title!.endIndex)
            
            let titleFound = publication.title!.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: titleRange, locale: nil)
            
            
            var subtitleFound: Range<String.Index>?
            
            if let subtitle = publication.subtitle {
                
                let subTitleRange = Range<String.Index>(subtitle.startIndex ..< subtitle.endIndex)
                
                subtitleFound = subtitle.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch, range: subTitleRange, locale: nil)
                
            }
            
            if titleFound != nil || subtitleFound != nil {
                filtered.append(publication)
            }
        }
        
        self.filteredUserCreatedPublications = filtered
        self.publicationsTableView.reloadData()
        
    }
    
    //MARK: FetchedResultsController Delegate
    // this will update the collection view after a new publication was created
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        
        switch type {
            
        case .Insert:
            if controller.sections![0].numberOfObjects == 1 {
                
                showTableView()
                publicationsTableView.reloadData()
            } else {
                publicationsTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            }
            
        case .Delete:
            if controller.sections![0].numberOfObjects == 0 {
                publicationsTableView.reloadData()
                hideTableView()
            } else {
                
                publicationsTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            }
            
        default:
            break
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PublishRootVC: UserDidDeletePublicationProtocol {
    
    func didDeletePublication(publication: Publication,  collectionViewIndex: Int) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func didTakeOffAirPublication(publication: Publication) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            
            
            //inform server and model
            FCModel.sharedInstance.foodCollectorWebServer.takePublicationOffAir(publication, completion: { (success) -> Void in
                
                //dissmiss publication details screen
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                
                if success{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        //update model
                        FCModel.sharedInstance.dataController.managedObjectContext.performBlockAndWait({ () -> Void in
                            
                            publication.endingData = NSDate()
                            publication.isOnAir = false
                            FCModel.sharedInstance.dataController.save()
                            
                            FCModel.sharedInstance.loadPublications()
                            FCModel.sharedInstance.loadUserCreatedPublications()
                            self.publicationsTableView.reloadData()
                        })
                    })
                }
                else{
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not take your event off air", aMessage: "try again later")
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                }
            })
        })
    }
}

