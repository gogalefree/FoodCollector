//
//  FDServer+GroupsFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 03/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    
    func fetchGroupsForUser(context: NSManagedObjectContext) {
                
        let userId = User.sharedInstance.userUniqueID
        if userId == 0 {return}
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: baseUrlString +  "users/\(userId)/groups")
        
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse  {
                
                print("response: \(serverResponse.description)", terminator: "")
                
             
                if error != nil || serverResponse.statusCode > 300 {
                    //handle error
                    return
                }
                
                if let data = data {
                    
                    do {
                        
                        let arrayOfGroups = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String : AnyObject]]
                        
                        if let groupsArray = arrayOfGroups {
                            
                            //Check If There're Groups To Delete
                            Group.deleteGroupsIfNeeded(groupsArray, context: context)
                            
                            for groupParams in groupsArray {
                                print("group:\n\(groupParams.description)")
                                
                                Group.instatiateGroupWithParams(groupParams, context: context)
                            }
                        }
                        
                    } catch {
                        print(error)
                    }
                    
                    
                    
                    
                }
                
            }
        })
        task.resume()
        
    }
    
    func fetchMembersForGroup(groupId: Int, completion: (success: Bool, group: Group?) -> Void ) {
               
        let url = NSURL(string: baseUrlString + "groups/\(groupId)/group_members")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse  {
                
                print("response: \(serverResponse.description)", terminator: "")
                
                
                if error != nil || serverResponse.statusCode > 300 {
                    //handle error
                    completion(success: false, group: nil)
                    return
                }
                
                if let data = data {
                    
                    do {
                        
                        let groupMembersDic = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String : AnyObject]
                        let membersArray = groupMembersDic?["members"] as? [[String : AnyObject]]
                        guard let membersDicts = membersArray else {
                            completion(success: false, group: nil)
                            return
                        }
                        
                        //the group is empty. delete it from the client
                        if membersDicts.count == 0 {
                            
                            Group.deleteGroupWithId(groupId)
                        }
                            
                        //handle Group Members
                        else {
                         
                            //if current user is not in the group - delete the group
                            if !GroupMember.currentUserIsMember(membersDicts) {
                                
                                Group.deleteGroupWithId(groupId)
                            }
                            
                            //update the group members
                            else {
                                
                                var aGroup: Group? = Group.fetchGroupWithId(groupId)
                                
                                if aGroup == nil {
                                   
                                    aGroup = NSEntityDescription.insertNewObjectForEntityForName(kGroupEntity, inManagedObjectContext: FCModel.sharedInstance.dataController.managedObjectContext) as? Group
                                }
                                
                                if let group = aGroup {
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        
                                        let moc = FCModel.sharedInstance.dataController.managedObjectContext
                                        
                                        //delete all existing
                                        group.deleteMembers()
                                        
                                        //create existing
                                        GroupMember.createOrUpdateMembersForGroup(membersDicts, group: group, context: moc)
                                        completion(success: true, group: group)
                                    })
                                    
                                } else {
                                    completion(success: false, group: nil)
                                }
                            }
                        }
                        
                        
                    }
                    catch {
                        print("error fetching MembersForGroup: \(error) " + #function)
                        completion(success: false, group: nil)
                        return
                    }
                }
                
            }
        })
        task.resume()
    }
}