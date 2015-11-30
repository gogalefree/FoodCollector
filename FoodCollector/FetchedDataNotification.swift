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

    let publication :FCPublication
    let type: NotificationType
    let title: String
    
    
    init(_ publication: FCPublication, type: NotificationType) {
    
        self.publication = publication
        self.type = type
        self.title = FetchedDataNotification.titleForType(type)
        super.init()
    }
    
    class func titleForType(type: NotificationType) -> String {
        
        var title = ""
        
        switch type {
        case .NewPublication:
            title = String.localizedStringWithFormat("New publication nearby:", "fetched data notification text: New publication nearby")
            
        case .DeletePublication:
            title = String.localizedStringWithFormat("An event ended nearby:", "fetched data notification text: An event ended nearby")
            
        case .Report:
            title = String.localizedStringWithFormat("New event received for:", "fetched data notification text: New event received for")
            
        case .Registration:
            title = String.localizedStringWithFormat("Another user is en route to pickup:", "fetched data notification text: Another user is en route to pickup:")
    
        }
        
        return title
    }
}
