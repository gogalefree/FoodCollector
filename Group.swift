//
//  Group.swift
//  FoodCollector
//
//  Created by Guy Freedman on 14/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
struct GroupData {
    
    var creatorId   : Int       = 0
    var name        : String    = ""
    var id          : Int       = 0
}

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
        //after the group is created, logedin User is added as a group Member
        FCModel.dataController.save()
        return group
    }

    class func adminGroupsForLogedinUser() -> [Group]? {
    
        let adminId = User.sharedInstance.userUniqueID
        let predicate = NSPredicate(format: "adminUserId = %@", NSNumber(long: adminId))
        let request = NSFetchRequest(entityName: kGroupEntity)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false

        do {
            
            let results = try moc.executeFetchRequest(request) as? [Group]
            return results
            
        } catch { print("error fetching groups for logedin user \(error)")}
        
        return nil
    }
    
    class func groupMemberGroupsForloginUser() -> [Group]? {
        
        var groups = [Group]()
        let groupMembers = GroupMember.membersForLoginUser()
        guard let members = groupMembers else {return nil}
        
        for member in members {
        
            if let group = member.belongToGroup {
                groups.append(group)
            }
        }
        
        return groups
    }
    
    class func fetchGroupWithId(groupId: Int) -> Group? {
       
        let predicate = NSPredicate(format: "id = %@",NSNumber(long: groupId))
        let request = NSFetchRequest(entityName: kGroupEntity)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false

        
        do {
            
            let results = try moc.executeFetchRequest(request) as? [Group]
            return results?.last
            
        } catch { print("error fetching groups for logedin user \(error)")}
        
        return nil
    }
    
    class func groupJsonWithGroupData(groupData: GroupData) -> NSData? {
        
        let groupDict   = ["user_id" : groupData.creatorId , "name" : groupData.name]
        let groupToSend = ["group" : groupDict]
        print("group to send: \(groupToSend)")
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(groupToSend, options: [])
            return data
        } catch {
            print("error creating group json \(error)")
        }

        return nil
    }
    
}
