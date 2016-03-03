//
//  ActivityLog+CoreDataProperties.swift
//  FoodCollector
//
//  Created by Guy Freedman on 03/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ActivityLog {

    @NSManaged var title: String?
    @NSManaged var type: NSNumber?
    @NSManaged var date: NSDate?

}
