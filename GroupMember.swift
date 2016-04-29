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

    static let moc = FCModel.sharedInstance.dataController.managedObjectContext
    
    class func initWith(name: String, id: Int, phoneNumber: String, userId: Int, isFoodonetUser: Bool, isAdmin: Bool, belongsToGroup: Group) -> GroupMember? {
        
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
        let predicate = NSPredicate(format: "userId = %@ && isAdmin = %@", NSNumber(long: memberId) , NSNumber(bool: false))
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try moc.executeFetchRequest(request) as? [GroupMember]
            return results
        } catch {
            print("error in membersForLoginUser \(error)")
        }
        
        return nil
    }
    
    class func createInitialMembers(members: [GroupMemberData] ,ForGroup group: Group, createAdmin: Bool) -> [GroupMember] {
        
        var membersToSend = [GroupMember]()
        
        //create admin
        if createAdmin{
            let admin =
            GroupMember.initWith(User.sharedInstance.userIdentityProviderUserName,
                id: 0,
                phoneNumber: User.sharedInstance.userPhoneNumber,
                userId: User.sharedInstance.userUniqueID,
                isFoodonetUser: true,
                isAdmin: true,
                belongsToGroup: group)
            
            if let groupAdmin = admin {
                membersToSend.append(groupAdmin)
                group.members?.setByAddingObject(groupAdmin)
            
            }
        }
        
        //create members
        for member in members {
            
            let aMember =
            GroupMember.initWith(member.name,
                id: 0,
                phoneNumber: member.phoneNumber,
                userId: 0,
                isFoodonetUser: false,
                isAdmin: false,
                belongsToGroup: group)
        
            if let newMember = aMember {
                membersToSend.append(newMember)
                group.members?.setByAddingObject(newMember)
            }
        }
        
        //save
        FCModel.sharedInstance.dataController.save()
        return membersToSend

    }
    
    class func groupMembersJson(members:[GroupMember]) -> NSData? {
       
        var membersArray = [[String:AnyObject]]()
        let members = members
        
        for member in members {
        
            let groupId = member.belongToGroup!.id!.integerValue
            let memberDict = ["name" : member.name! , "user_id" : member.userId!.integerValue , "is_admin" : member.isAdmin!.boolValue , "Group_id" : groupId , "phone_number" : member.phoneNumber!]
            membersArray.append(memberDict as! [String : AnyObject])
        }
        
        let dictToSend = ["group_members" :  membersArray]
        print("group members dict to send: \(dictToSend)")
        
        do {
            
            return try NSJSONSerialization.dataWithJSONObject(dictToSend, options: [])
        } catch {
            print("error creating group members array to json: \(error)")
        }
        
        return nil
    }
    
    class func deleteGroupMember(memberToDelete: GroupMember, group: Group) {
        
        let memberToDelete = memberToDelete
        
        let members = NSMutableSet(set: group.members!)
        members.removeObject(memberToDelete)
        group.members = NSSet(set: members)
        
        GroupMember.moc.deleteObject(memberToDelete)

        FCModel.sharedInstance.foodCollectorWebServer.deleteGroupMember(memberToDelete)
    }
    
    class func createOrUpdateMembersForGroup(membersArray: [[String : AnyObject]],
        group: Group, context: NSManagedObjectContext) {
            
            for memberParams in membersArray {
                
                let phoneNumber = memberParams["phone_number"] as? String ?? ""
                let groupId = group.id!.integerValue
                
                let request = NSFetchRequest(entityName: kGroupMemberEntity)
                let predicate = NSPredicate(format: "phoneNumber == %@ && belongToGroup.id = %@ ", phoneNumber , NSNumber(integer: groupId))
                request.predicate = predicate
                
                context.performBlock({ () -> Void in
                    
                    do {
                        let results = try context.executeFetchRequest(request) as? [GroupMember]
                        if let groupMembers = results {
                        
                            if groupMembers.count == 0 {
                                
                                let member = NSEntityDescription.insertNewObjectForEntityForName(kGroupMemberEntity, inManagedObjectContext: context) as? GroupMember
                                
                                if let newMember = member {
                                
                                    newMember.updateWithParams(memberParams, context: context, group: group)
                                }
                                
                            }
                            
                            else if groupMembers.count == 1 {
                                
                                let aMember = groupMembers.last!
                                aMember.updateWithParams(memberParams, context: context, group: group)

                            }
                            
                            else {
                                
                                
                                    //Handle Duplicates
                                    let aMember = groupMembers.last!
                                    aMember.updateWithParams(memberParams, context: context, group: group)
                                   
                                    
                                    for _ in 0  ..< groupMembers.count - 1  {
                                        let member = groupMembers.first!
                                        context.deleteObject(member)
                                    }
                                }
                            }
                        }
                    
                     catch {
                        print("error create or update Group Member \(error)")
                    }
                })
            }
    }
    
    func updateWithParams(params: [String : AnyObject], context: NSManagedObjectContext, group: Group) {
        
        context.performBlockAndWait { () -> Void in
            
            let memberId = params["id"] as? Int ?? 0
            //let memberGroupId = params["Group_id"] as? Int ?? 0
            let isAdimn = params["is_admin"] as? Int ?? 0
            let memberName = params["name"] as? String ?? ""
            let memberPhoneNumber = params["phone_number"] as? String ?? ""
            let memberUserId = params["user_id"] as? Int ?? 0
            
            self.id = memberId
            self.isFoodonetUser = memberUserId == 0 ? false : true
            self.name = memberName
            self.phoneNumber = memberPhoneNumber
            self.userId = memberUserId
            self.isAdmin = isAdimn == 0 ? false : true
            self.didInformServer = true
            self.belongToGroup = group
            
            if group.members == nil {group.members = Set<GroupMember>()}
            group.members?.setByAddingObject(self)
            
            do {
                try context.save()
            } catch {
                print ("error \(error) ")
            }
        }
    }
    
    class func currentUserIsMember(membersDicts: [[String : AnyObject]]) -> Bool {
        
        print("members: \(membersDicts)")
        
        let arrivedIds: [NSNumber] = membersDicts.map { dictionary in
            return NSNumber(integer: (dictionary["user_id"] as? Int ?? -1))
        }
        
        let foundId = arrivedIds.filter {number in number == NSNumber(integer: User.sharedInstance.userUniqueID)}
        
        if foundId.count > 0 {
            return true
        }
        
        return false
    }
}
