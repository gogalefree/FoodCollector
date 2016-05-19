//
//  FDSpotlightIndexer.swift
//  FoodCollector
//
//  Created by Guy Freedman on 19/05/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import CoreSpotlight

class FDSpotlightIndexer: NSObject {

    let kSpotlightIdentifiersKey = "kSpotlightIdentifiersKey"
    var spotlightIdentifiers = [String]()
    
    func startIndexing() {
        
        //load Identifiers
        loadIdentifiers()
        
        //clear current identifiers
        deleteExistingIdentifiers()
        
        
    }
    
    func deleteExistingIdentifiers(){
        
        if #available(iOS 9.0, *) {
            CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler({ (error) in
              
                self.spotlightIdentifiers.removeAll()
                self.createSpotlightIndex()
            })
        } else {
            // Fallback on earlier versions
            
        }
    }
    
    func createSpotlightIndex() {
        
        if #available(iOS 9.0, *) {
     
            let publications = FCModel.sharedInstance.publications
            for publication in publications {
            
            
                let identifier = "\(publication.uniqueId!.integerValue).\(publication.version!.integerValue)"
                spotlightIdentifiers.append(identifier)
            
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: "Event" as String)
        
                // Add metadata that supplies details about the item.
                attributeSet.title = publication.title
                attributeSet.contentDescription = publication.address
                attributeSet.latitude = publication.coordinate.latitude
                attributeSet.longitude = publication.longitutde
                attributeSet.supportsNavigation = true
                attributeSet.keywords = publication.title!.characters.split{$0 == " "}.map(String.init)
                attributeSet.displayName = publication.title
                let imageData = publication.photoBinaryData != nil ? publication.photoBinaryData : UIImageJPEGRepresentation(UIImage(named: "Big_Logo")!, 1)
                attributeSet.thumbnailData = imageData
                
                // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
                let item = CSSearchableItem(uniqueIdentifier: identifier, domainIdentifier: "Foodonet", attributeSet: attributeSet)
                item.expirationDate = publication.endingData
                
                
                // Add the item to the on-device index.
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { error in
                    if error != nil {
                    print(error?.localizedDescription)
                    }
                    else {
                        print("Item indexed.")
                        self.saveIdentifiers()
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func loadIdentifiers() {
        
        if let existingIdentifiers = NSUserDefaults.standardUserDefaults().objectForKey(kSpotlightIdentifiersKey) as? [String]{
            
            spotlightIdentifiers = existingIdentifiers
        }
    }
    
    func saveIdentifiers() {
        NSUserDefaults.standardUserDefaults().setObject(spotlightIdentifiers, forKey: kSpotlightIdentifiersKey)
    }
}
