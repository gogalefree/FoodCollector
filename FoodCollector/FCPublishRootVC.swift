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
class FCPublishRootVC : UIViewController {
    
    @IBOutlet var collectionView:UICollectionView!
    var userCreatedPublications = [FCPublication]()
    
   
    
    func editUserCreatedPublication() {
        
    }
    
    func newPublication() {
        
    }
    
}

