//
//  PublicationReport+CoreDataProperties.swift
//  FoodCollector
//
//  Created by Guy Freedman on 24/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PublicationReport {

    @NSManaged var activeDeviceDecUUID: String?
    @NSManaged var dateOfReport: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var publicationId: NSNumber?
    @NSManaged var publicationVersion: NSNumber?
    @NSManaged var reoprterUserName: String?
    @NSManaged var report: NSNumber?
    @NSManaged var reporterContactInfo: String?
    @NSManaged var reporterUserId: NSNumber?
    @NSManaged var reporterImageData: NSData?
    @NSManaged var publication: Publication?

}
