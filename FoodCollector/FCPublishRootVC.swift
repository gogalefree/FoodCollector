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
        userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
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
        var status = ""
        var statusImg : UIImage
        let publication = userCreatedPublications[indexPath.item]
        let pubTitle = publication.title
        let locDateString = FCDateFunctions.localizedDateStringShortStyle(publication.endingDate)
        
        if FCDateFunctions.PublicationDidExpired(publication.endingDate){
            status = String.localizedStringWithFormat("Not Active" , "the puclication is off the air")
            statusImg = UIImage(named: "Red-dot")!
        }
        else {
            status = String.localizedStringWithFormat("Active until: \(locDateString))" , "the publication is active untill this date")
            statusImg = UIImage(named: "Green-dot")!
        }
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as FCPublishRootVCCustomCollectionViewCell
        
        cell.FCPublisherEventTitle.text = pubTitle
        cell.FCPublisherEventStatus.text = status
        cell.FCPublisherEventStatusIcon.image = statusImg
        
        return cell
    }
    
    
    
    func editUserCreatedPublicationAction() {
        
    }
    
    func newPublicationAction() {
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let size = CGSizeMake(self.collectionView.bounds.size.width , 90)
        return size
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
        label.text = String.localizedStringWithFormat("You have not created a publication yet.\n\nClick the + button to create a new publication." , "no user created publications message")
        self.view.addSubview(label)
    }
    
}
