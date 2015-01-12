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


///
/// show all user created publication: live and expired.
/// contains a button for creating a new Publication.
/// clicking an item starts’ editing mode of that item.
///
class FCPublishRootVC : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    @IBOutlet var collectionView:UICollectionView!
    
    var userCreatedPublications = [FCPublication]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userCreatedPublications = FCDateFunctions.sortPublicationsByEndingDate(FCModel.sharedInstance.userCreatedPublications)

        collectionView.delegate = self
        if userCreatedPublications.count == 0 {
            collectionView.alpha = 0.0
            displayNoPublicatiosMessage()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userCreatedPublications.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let reusableId = "FCPublishCollectionViewCell"
        let publication = userCreatedPublications[indexPath.item]
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as FCPublishRootVCCustomCollectionViewCell
        cell.publication = publication
        
        // The tag property will be used later in the segue to identify
        // the publication item clicked by the user for editing.
        cell.tag = indexPath.item
        
        return cell
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSizeMake(self.collectionView.bounds.size.width , 90)
        return size
    }
    
    // Check which segue was used to go to the FCPublicationEditorTVC view.
    //
    // If the segue identifier is "showNewPublicationEditorTVC" - do nothing. In the
    // FCPublicationEditorTVC class we will check to see if var publication is empty or nil
    // and if it is, we will disply a new publication table.
    //
    // If the segue identifier is "showEditPublicationEditorTVC" we will pass on the
    // publication object that corresponds to the clicked cell in the collection view
    // and display the publication's content in the FCPublicationEditorTVC class.
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "showEditPublicationEditorTVC") {
            let pubEditorTVC = segue!.destinationViewController as FCPublicationEditorTVC
            pubEditorTVC.publication = userCreatedPublications[sender.tag]
        }
    }
    
    
    func displayNoPublicatiosMessage(){
        let recWidth = FCDeviceData.screenWidth()/1.4
        let recHight = FCDeviceData.screenHight()/1.4
        let recCenterX = FCDeviceData.screenWidth()/2
        let recCenterY = FCDeviceData.screenHight()/2
        let fontSize = FCDeviceData.screenWidth()/10 - 9
        
        var label = UILabel(frame: CGRectMake(0, 0, recWidth, recHight))
        label.center = CGPointMake(recCenterX, recCenterY)
        
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(fontSize)
        label.text = String.localizedStringWithFormat("You have not created a publication yet.\n\nClick the + button to create a new publication." , "No user created publications message")
        self.view.addSubview(label)
    }
    
}
