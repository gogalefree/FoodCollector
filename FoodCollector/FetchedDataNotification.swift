//
//  FetchedDataNotification.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class FetchedDataNotification: NSObject {
    
    enum NotificationType {case NewPublication, DeletePublication, Report, Registration}

    let publication :Publication
    let type: NotificationType
    let title: String
    
    
    init(_ publication: Publication, type: NotificationType) {
    
        self.publication = publication
        self.type = type
        self.title = FetchedDataNotification.titleForType(type)
        super.init()
    }
    
    class func titleForType(type: NotificationType) -> String {
        
        var title = ""
        
        switch type {
        case .NewPublication:
            title = kNewEventMessageTitle
            
        case .DeletePublication:
            title = NSLocalizedString("Event Ended Near You", comment:"Title for a notification")
            
        case .Report:
            title = NSLocalizedString("New Event Update", comment:"Title for a notification")
            
        case .Registration:
            title = NSLocalizedString("User’s Coming To Pickup", comment:"fetched data notification text: Another user is en route to pickup:")
    
        }
        
        return title
    }
    
    func toString() -> String {
        return String("title: \(title)\ntype: \(type)\npublication title: \(publication.title!)")
    }
}
