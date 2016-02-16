//
//  Group.swift
//  FoodCollector
//
//  Created by Guy Freedman on 14/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData


class Group: NSManagedObject {

    static let moc = FCModel.dataController.managedObjectContext

    class func initWith(name: String, id: Int, adminId: Int) -> Group? {
        
        let newGroup = NSEntityDescription.insertNewObjectForEntityForName(kGroupEntity, inManagedObjectContext: moc) as? Group
        guard let group = newGroup else {return nil}
        group.name = name
        group.id = id
        group.adminUserId = adminId
        return group
    }

    class func fetchGorupsForLogedinUser() -> [Group]? {
    
        let adminId = User.sharedInstance.userUniqueID
        let predicate = NSPredicate(format: "adminUserId == %@", adminId)
        let request = NSFetchRequest(entityName: kGroupEntity)
        request.predicate = predicate
        
        do {
            
            let results = try moc.executeFetchRequest(request) as? [Group]
            return results
            
        } catch { print("error fetching groups for logedin user \(error)")}
        
        return nil
    }
    
    class func fetchGroupWithId(groupId: Int) -> Group? {
       
        let predicate = NSPredicate(format: "id == %@", groupId)
        let request = NSFetchRequest(entityName: kGroupEntity)
        request.predicate = predicate
        
        do {
            
            let results = try moc.executeFetchRequest(request) as? [Group]
            return results?.last
            
        } catch { print("error fetching groups for logedin user \(error)")}
        
        return nil
    }
    
    
    
}
