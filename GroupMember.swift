//
//  GroupMember.swift
//  FoodCollector
//
//  Created by Guy Freedman on 14/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData


class GroupMember: NSManagedObject {

    static let moc = FCModel.dataController.managedObjectContext

    class func initWith(name: String, id: Int, phoneNumber: String, userId: Int, isFoodonetUser: Bool, groupId: Int) -> GroupMember? {
        
        let newGroupMember = NSEntityDescription.insertNewObjectForEntityForName(kGroupMemberEntity, inManagedObjectContext: moc) as? GroupMember
        guard let groupMember = newGroupMember else {return nil}
        groupMember.name = name
        groupMember.id = id
        groupMember.userId = userId
        groupMember.phoneNumber = phoneNumber
        groupMember.isFoodonetUser = isFoodonetUser
        let group = Group.fetchGroupWithId(groupId)
        if let belongsToGroup = group {
            
            groupMember.belongToGroup = belongsToGroup
        }
        return groupMember
    }
    
    class func membersForLoginUser() -> [GroupMember]? {
        
        let memberId = User.sharedInstance.userUniqueID
        let request  = NSFetchRequest(entityName: kGroupMemberEntity)
        let predicate = NSPredicate(format: "userId == %@", memberId)
        request.predicate = predicate
        
        do {
            
            let results = try moc.executeFetchRequest(request) as? [GroupMember]
            return results
        } catch {
            print("error in membersForLoginUser \(error)")
        }
        
        return nil
    }
}
