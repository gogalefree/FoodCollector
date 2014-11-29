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
    
    
}

