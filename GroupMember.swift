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

    class func initWith(name: String, id: Int, phoneNumber: String, userId: Int, isFoodonetUser: Bool, groupId: Int, isAdmin: Bool, belongsToGroup: Group) -> GroupMember? {
        
        let newGroupMember = NSEntityDescription.insertNewObjectForEntityForName(kGroupMemberEntity, inManagedObjectContext: moc) as? GroupMember
        guard let groupMember       = newGroupMember else {return nil}
        groupMember.name            = name
        groupMember.id              = id
        groupMember.userId          = userId
        groupMember.phoneNumber     = phoneNumber
        groupMember.isFoodonetUser  = isFoodonetUser
        groupMember.isAdmin         = isAdmin
        groupMember.belongToGroup   = belongsToGroup
        return groupMember
    }
    
    class func membersForLoginUser() -> [GroupMember]? {
        
        let memberId = User.sharedInstance.userUniqueID
        let request  = NSFetchRequest(entityName: kGroupMemberEntity)
        let predicate = NSPredicate(format: "userId = %@", NSNumber(long: memberId))
        request.predicate = predicate
        
        do {
            
            let results = try moc.executeFetchRequest(request) as? [GroupMember]
            return results
        } catch {
            print("error in membersForLoginUser \(error)")
        }
        
        return nil
    }
    
    class func createInitialMembers(members: [GroupMemberData] ,ForGroup group: Group) {
        
        var membersToSend = [GroupMember]()
        
        //create admin
        let admin =
        GroupMember.initWith(User.sharedInstance.userIdentityProviderUserName,
            id: 0,
            phoneNumber: User.sharedInstance.userPhoneNumber,
            userId: User.sharedInstance.userUniqueID,
            isFoodonetUser: true,
            groupId: group.id!.integerValue,
            isAdmin: true,
            belongsToGroup: group)
        
        if let groupAdmin = admin {membersToSend.append(groupAdmin)}
        
        //create members
        for member in members {
            
            let aMember =
            GroupMember.initWith(member.name,
                id: 0,
                phoneNumber: member.phoneNumber,
                userId: 0,
                isFoodonetUser: false,
                groupId: group.id!.integerValue,
                isAdmin: false,
                belongsToGroup: group)
        
            if let newMember = aMember {membersToSend.append(newMember)}
        }
        
        //save
        //FCModel.dataController.save()
        
        //post to server
    }
    
    
}
