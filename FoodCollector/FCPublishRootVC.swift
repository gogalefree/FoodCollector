//
//  FCPublishRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//

import UIKit
import Foundation

///
/// show all user created publication: live and expired.
/// contains a button for creating a new Publication.
/// clicking an item starts’ editing mode of that item.
///
class FCPublishRootVC : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView:UICollectionView!
    var userCreatedPublications = [FCPublication]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
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
        let pubTitle = publication.title
        let locDateString = NSDateFormatter.localizedStringFromDate(publication.startingDate, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath) as FCPublishRootVCCustomCollectionViewCell
        
        cell.FCPublisherEventTitle.text = pubTitle
        cell.FCPublisherEventStatus.text = locDateString
        return cell
        
    }

   
    
    func editUserCreatedPublication() {
        
    }
    
    func newPublication() {
        
    }
    
}

