//
//  Group+CoreDataProperties.swift
//  FoodCollector
//
//  Created by Guy Freedman on 20/05/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Group {

    @NSManaged var adminUserId: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var members: NSSet?

}
