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
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: FCDeviceData.screenWidth(), height: 90)
        collectionView.collectionViewLayout = layout
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
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as FCPublishRootVCCustomCollectionViewCell
        
        if FCDateFunctions.PublicationDidExpired(publication.endingDate){
            status = "Not Active" // Localizable string
            statusImg = UIImage(named: "Red-dot")!
            //cell.backgroundColor = UIColor(red: 1.00, green: 0.81, blue: 0.82, alpha: 1.00)
        }
        else {
            status = "Active (until: \(locDateString))" // Localizable string
            statusImg = UIImage(named: "Green-dot")!
            //cell.backgroundColor = UIColor(red: 0.86, green: 1.00, blue: 0.80, alpha: 1.00)

        }
        
        
        cell.FCPublisherEventTitle.text = pubTitle
        cell.FCPublisherEventStatus.text = status
        cell.FCPublisherEventStatusIcon.image = statusImg
        //cell.layer.borderWidth = 1.0
        //cell.layer.borderColor = UIColor.grayColor().CGColor
        return cell
        
    }

   
    
    func editUserCreatedPublication() {
        
    }
    
    func newPublication() {
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        layout.itemSize = CGSize(width: FCDeviceData.screenWidth(), height: 90)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

