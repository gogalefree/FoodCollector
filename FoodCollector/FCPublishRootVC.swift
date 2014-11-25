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
class FCPublishRootVC : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView:UICollectionView!
    
    var userCreatedPublications = [FCPublication]()
    let fLowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
        if userCreatedPublications.count == 0 {
            collectionView.alpha = 0.0
            displayNoPublicatiosMessage()
        }
        else {
            fLowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            fLowLayout.minimumInteritemSpacing = 0
            fLowLayout.minimumLineSpacing = 0
            fLowLayout.itemSize = CGSize(width: FCDeviceData.screenWidth(), height: 90)
            collectionView.collectionViewLayout = fLowLayout
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
            status = "Not Active" // Localizable string
            statusImg = UIImage(named: "Red-dot")!
        }
        else {
            status = "Active (until: \(locDateString))" // Localizable string
            statusImg = UIImage(named: "Green-dot")!
        }
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as FCPublishRootVCCustomCollectionViewCell
        
        cell.FCPublisherEventTitle.text = pubTitle
        cell.FCPublisherEventStatus.text = status
        cell.FCPublisherEventStatusIcon.image = statusImg
        
        return cell
        
    }

   
    
    func editUserCreatedPublication() {
        
    }
    
    func newPublication() {
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        fLowLayout.itemSize = CGSize(width: FCDeviceData.screenWidth(), height: 90)
        collectionView.collectionViewLayout.invalidateLayout()
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
        label.numberOfLines = 0 //removes any maximum limit, and uses as many lines as needed
        //label.shadowColor = UIColor.lightGrayColor()
        //label.shadowOffset = CGSize(width: 1,height: 2)
        label.font = UIFont.systemFontOfSize(fontSize)
        // Localizable string
        label.text = "You have not created a publication yet.\n\nClick the + button to create a new publication."
        self.view.addSubview(label)
    }
    
}

