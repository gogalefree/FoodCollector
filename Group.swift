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


    class func initWith(name: String, id: Int, adminId: Int) -> Group? {
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let newGroup = NSEntityDescription.insertNewObjectForEntityForName(kGroupEntity, inManagedObjectContext: moc) as? Group
        guard let group = newGroup else {return nil}
        group.name = name
        group.id = id
        group.adminUserId = adminId
        group.createdAt = NSDate()
        //after the group is created, logedin User is added as a group Member
        FCModel.sharedInstance.dataController.save()
        return group
    }

    class func adminGroupsForLogedinUser() -> [Group]? {
    
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
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
    
    class func groupMemberGroupsForloggedinUser() -> [Group]? {
        
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
       
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let predicate = NSPredicate(format: "id = %@",NSNumber(integer: groupId))
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
    
    class func deleteGroupsIfNeeded(groupsArray: [[String : AnyObject]], context: NSManagedObjectContext) {
        
        let incomingIds = groupsArray.map {dictionary in
            return NSNumber(integer: dictionary["group_id"] as? Int ?? -1)
        }
        
        let toDeletePredicate = NSPredicate(format: "NOT (id in %@)", argumentArray: [incomingIds])
        let deleteFetchRequest   = NSFetchRequest(entityName: kGroupEntity)
        deleteFetchRequest.predicate = toDeletePredicate
        
        context.performBlockAndWait { () -> Void in
            
            defer {
                
                do {
                    try context.save()
                    
                } catch {
                    print("error deleting old publications \(error)" + #function)
                }
            }
            
            let groupsToDelete = try! context.executeFetchRequest(deleteFetchRequest) as? [Group]
            
            if let toDelete = groupsToDelete {
               
                for group in toDelete {
                    
                    context.deleteObject(group)
                }
            }
        }
    }

    
    class func instatiateGroupWithParams(groupParams: [String : AnyObject], context: NSManagedObjectContext) {
        
        context.performBlockAndWait { () -> Void in
            
            let groupId = groupParams["group_id"] as? Int ?? 0
            
            if groupId == 0 {return}
            
            let request = NSFetchRequest(entityName: kGroupEntity)
            let predicate = NSPredicate(format: "id = %@", NSNumber(integer: groupId))
            request.predicate = predicate
            
            do {
                let results = try context.executeFetchRequest(request) as? [Group]
                guard let groups = results else {return}
                
                if groups.count == 0 {
                    
                    let group = NSEntityDescription.insertNewObjectForEntityForName(kGroupEntity, inManagedObjectContext: context) as! Group
                    group.updateWithParams(groupParams, context: context)
                    ActivityLog.activityLog(nil, group: group, type: ActivityLog.LogType.NewGroup.rawValue, context: context)
                }
                
                else if groups.count == 1 {
                    let group = groups.last!
                    
                    group.deleteMembers()
                    group.updateWithParams(groupParams, context: context)
                }
                
                else {
                    
                    let group = groups.last!
                    group.deleteMembers()
                    group.updateWithParams(groupParams, context: context)
                    
                    //delete duplicates
                    for _ in 0  ..< groups.count - 1  {
                        let groupToDelete = groups.first!
                        context.delete(groupToDelete)
                    }

                }
                
            }catch  {
                print("error fetching group \(error) " + #function)
            }
            
        }
        
        
    }
    
    func updateWithParams(groupParams: [String : AnyObject], context: NSManagedObjectContext) {
        
        
        let groupAdminId = groupParams["user_id"] as? Int ?? 0
        let groupId = groupParams["group_id"] as? Int ?? 0
        let groupName = groupParams["group_name"] as? String ?? ""
        
        let unixTString = groupParams["created_at"] as? String ?? ""
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let createdAt = formatter.dateFromString(unixTString)
        
        context.performBlockAndWait { () -> Void in
            
            self.id = groupId
            self.name = groupName
            self.adminUserId = groupAdminId
            self.members = Set<GroupMember>()
            self.createdAt = createdAt ?? NSDate()
         
            let membersArray = groupParams["members"] as? [[String : AnyObject]]
            guard let members = membersArray else {return}
            
            
            
            //create new
            GroupMember.createOrUpdateMembersForGroup(members, group: self, context: context)
            
            do {
                try context.save()
            } catch {
                print("error saving group \(error) " + #function )
            }
        }
    }
    
    class func deleteGroupWithId(groupId: Int) {
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let group = Group.fetchGroupWithId(groupId)
        guard let groupToDelete = group else {return}
        
        moc.performBlock { () -> Void in
            moc.deleteObject(groupToDelete)
            FCModel.sharedInstance.dataController.save()
        }
    }
    
    func deleteMembers() {
        
        for member in self.members! {
            
            let moc = member.managedObjectContext!
            moc.performBlock({ () -> Void in
                moc.deleteObject(member as! NSManagedObject)
            })
        }
    }
}
