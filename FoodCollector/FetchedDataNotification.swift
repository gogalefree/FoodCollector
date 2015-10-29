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
            title = String.localizedStringWithFormat("פרסום חדש באזורך:", "fetched data notification text")
            
        case .DeletePublication:
            title = String.localizedStringWithFormat("ארוע הסתיים באזורך:", "fetched data notification text")
            
        case .Report:
            title = String.localizedStringWithFormat("התקבל דיווח חדש עבור:", "fetched data notification text")
            
        case .Registration:
            title = String.localizedStringWithFormat("משתמש נוסף בדרך לאסוף:", "fetched data notification text")
    
        }
        
        return title
    }
}
