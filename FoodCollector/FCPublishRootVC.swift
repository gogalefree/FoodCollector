//
//  FCPublishRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

let kPublisherRootVCHeaderViewReusableId = "collectionViewHeader"
///
/// show all user created publication: live and expired.
/// contains a button for creating a new Publication.
/// clicking an item starts’ editing mode of that item.
///
class FCPublishRootVC : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UISearchBarDelegate , UIScrollViewDelegate , NSFetchedResultsControllerDelegate{
    
    @IBOutlet var collectionView:UICollectionView!
    var noUserCreatedPublicationMessageLabel: UILabel?
    
    var filteredUserCreatedPublications = [Publication]()
    var collectionViewHidden = false
    
    var searchBar: UISearchBar!
    var searchTextCharCount = 0
    var onceToken = 0
    var isFiltered = false
    var unPresentedPublications = [Publication]()
    
    var _fetchedResultsController :NSFetchedResultsController?
    
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {return _fetchedResultsController!}
        
        let moc = FCModel.dataController.managedObjectContext
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
            print("error fetching activity logs by fetchedResultsController \(error) " + __FUNCTION__)
        }
        
        return _fetchedResultsController!
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.delegate = self
        if fetchedResultsController.sections![0].numberOfObjects == 0 {
            
            hideCollectionView()
        }
        else {
            
            
            collectionView.userInteractionEnabled = true
            collectionView.scrollEnabled = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        if fetchedResultsController.sections![0].numberOfObjects > 0 {
            showCollectionView()
        } else {
            hideCollectionView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        dispatch_once(&onceToken) {
            self.collectionView.contentOffset.y = 20
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAController.reportsAnalyticsForScreen(kFAPublisherRootVCScreenName)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isFiltered {return filteredUserCreatedPublications.count}
        return fetchedResultsController.sections![0].numberOfObjects
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        var publication: Publication
        
        if isFiltered {
            publication = filteredUserCreatedPublications[indexPath.item]
        }
        else {
            publication = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Publication
 
        }
        
        let reusableId = "FCPublishCollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as! FCPublishRootVCCustomCollectionViewCell
        cell.publication = publication
        
        // The tag property will be used later in the segue to identify
        // the publication item clicked by the user for editing.
        cell.tag = indexPath.item
        
        return cell
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if self.collectionView != nil {
        
            self.collectionView.collectionViewLayout.invalidateLayout()
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSizeMake(self.collectionView.bounds.size.width , 90)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var publication: Publication
        
        if isFiltered {
            publication = filteredUserCreatedPublications[indexPath.item]
        }
        else {
            publication = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Publication
            
        }
        
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        
        publicationDetailsTVC?.setupWithState(PublicationDetailsTVCViewState.Publisher, caller: PublicationDetailsTVCVReferral.MyPublications, publication: publication, publicationIndexPath: indexPath.item)
        
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
        
        publicationDetailsTVC?.deleteDelgate = self
        
        let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }

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
    
    
    //MARK: - User deleted his own user created publication
    //Segue initiated by delete button in PublicationEditorTVC
    //DELETE is automatically managed by NSFetchedResultsController
    //Should Deprecate
    @IBAction func unwindWithDeletePublication(segue: UIStoryboardSegue) {
    
        //if the state is not .Edit new the user cant delete
        let publicationEditorTVC = segue.sourceViewController as! PublicationEditorTVC
        if publicationEditorTVC.state != .EditPublication {return}
        
        let pubicationToDelete = publicationEditorTVC.publication!

            if self.fetchedResultsController.fetchedObjects?.count == 0 {
                hideCollectionView()
            }
        
        //delete from model
        FCModel.sharedInstance.deletePublication(pubicationToDelete, deleteFromServer: true)
    
    }
    
    func hideCollectionView() {
        collectionView.alpha = 0
        collectionViewHidden = true
        displayNoPublicatiosMessage()
    }
    
    func showCollectionView() {
        self.collectionViewHidden = false
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.collectionView.alpha = 1
            if let label = self.noUserCreatedPublicationMessageLabel {
                label.alpha = 0
                label.removeFromSuperview()
            }
        })
    }
    
    
    func displayNoPublicatiosMessage(){
        
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
            label.text = NSLocalizedString("Hi,\nWhat would you like to share?" , comment:"No user created publications message")
            self.view.addSubview(label)
        }
    }
    
    
    //MARK: - UISearchBar
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableview:UICollectionReusableView!
        
        
        
        if (kind == UICollectionElementKindSectionHeader) {
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: kPublisherRootVCHeaderViewReusableId, forIndexPath: indexPath) as! FCPublisherRootVCCollectionViewHeaderCollectionReusableView
            
            headerView.setUp()
            self.searchBar = headerView.searchBar
            self.searchBar.delegate = self
            reusableview = headerView
        }
        
        return reusableview
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //user is deleting
        //show all publications
        if searchText == "" || searchText.characters.count < self.searchTextCharCount{
            
            self.isFiltered = false
            self.collectionView.reloadData()
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
        self.collectionView.reloadData()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.collectionView.contentOffset.y = 20
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
            self.collectionView.reloadData()
        } catch {
            print("error refetching in publisher root vc: \(error)")
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        self.searchBar.resignFirstResponder()
    }
    
    func searchPublications(text: String) {
        
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
        
        self.filteredUserCreatedPublications = filtered
        self.collectionView.reloadData()
        
      }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    


//MARK: FetchedResultsController Delegate
// this will update the collection view after a new publication was created
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    

        switch type {
            
        case .Insert:
            if controller.sections![0].numberOfObjects == 1 {collectionView.reloadData()} else {
                collectionView.insertItemsAtIndexPaths([newIndexPath!])
            }
            
        case .Delete:
            if controller.sections![0].numberOfObjects == 0 {
                collectionView.reloadData()
                hideCollectionView()
            } else {
                
                collectionView.deleteItemsAtIndexPaths([indexPath!])
            }
            
        default:
            break
        }
    }
    
}

extension FCPublishRootVC: UserDidDeletePublicationProtocol {

    //DEPRECATED v1.0.9
    func didDeletePublication(publication: Publication,  collectionViewIndex: Int) {

    }
    //End Deprecation
    
    
    func didTakeOffAirPublication(publication: Publication) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in

            //update model
            FCModel.dataController.managedObjectContext.performBlock({ () -> Void in
                
                publication.endingData = NSDate()
                publication.isOnAir = false
                FCModel.dataController.save()
            })
            
            
            //inform server and model
            FCModel.sharedInstance.foodCollectorWebServer.takePublicationOffAir(publication, completion: { (success) -> Void in
                
                if success{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                       
                        FCModel.sharedInstance.loadPublications()
                        FCModel.sharedInstance.loadUserCreatedPublications()
                        self.collectionView.reloadData()

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
