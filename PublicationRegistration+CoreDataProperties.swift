//
//  PublicationRegistration+CoreDataProperties.swift
//  FoodCollector
//
//  Created by Guy Freedman on 27/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PublicationRegistration {

    @NSManaged var activeDeviceUUID: String?
    @NSManaged var collectorContactInfo: String?
    @NSManaged var collectorName: String?
    @NSManaged var collectorUserId: NSNumber?
    @NSManaged var dateOfRegistration: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var publicationId: NSNumber?
    @NSManaged var publicationVersion: NSNumber?
    @NSManaged var publication: Publication?

}
