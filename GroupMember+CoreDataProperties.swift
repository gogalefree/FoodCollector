//
//  GroupMember+CoreDataProperties.swift
//  FoodCollector
//
//  Created by Guy Freedman on 18/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GroupMember {

    @NSManaged var id: NSNumber?
    @NSManaged var isFoodonetUser: NSNumber?
    @NSManaged var name: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var userId: NSNumber?
    @NSManaged var isAdmin: NSNumber?
    @NSManaged var didInformServer: NSNumber?
    @NSManaged var belongToGroup: Group?

}
