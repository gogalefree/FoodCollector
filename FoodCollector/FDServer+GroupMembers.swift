//
//  FDServer+GroupMembers.swift
//  FoodCollector
//
//  Created by Guy Freedman on 21/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {

    func postGroupMembers(members: [GroupMember], completion: (isFoodonetUser: Bool) -> Void) -> Void {
    
        let myMembers = members
        guard let data = GroupMember.groupMembersJson(myMembers) else {return}
        
        let url = NSURL(string: baseUrlString + "group_members.json")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod  = "POST"
        request.HTTPBody    = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            taskData, response, error -> () in
            
            if error != nil {
                
                print("error sending group members \(error)")
                return
            }
            
            guard let response = response as? NSHTTPURLResponse , incomingData = taskData else {print("no response sending group members \(error)") ; return}
            
            print("response: \(response)")
            if response.statusCode == 200 || response.statusCode == 201 {
                
                let responseParams = try? NSJSONSerialization.JSONObjectWithData(incomingData, options: []) as? [[String: AnyObject]]
                guard let params = responseParams else {print("error parsing params from group members response \(error)") ; return}
                print("params: \(params)")
                
                for memberDict in params! {
                    
                    print("member: \(memberDict)")
                
                    let id = memberDict["id"] as? Int ?? 0
                    let userId = memberDict["user_id"] as? Int ?? 0
                    let name = memberDict["name"] as? String ?? ""
                    
                    let groupMember = myMembers.filter {(member) in member.name == name }
                    print("group member count should be 1 and is: \(groupMember.count)")

                    if groupMember.count > 0 {
                        
                        let foundMember = groupMember.first
                        if let member = foundMember {
                            
                            member.userId = userId
                            member.id     = id
                            member.didInformServer = true
                            member.isFoodonetUser = true
                            print("member name: \(member.name)")
                            print("member id: \(member.id)")
                            print("member userid: \(member.userId)")
                            completion(isFoodonetUser: true)
                        }
                    }
                    
                    FCModel.sharedInstance.dataController.save()
                        
                        
                }
            }
                
            else {
                
            
                ("error with request. response is not 200 \(response)")
            }
            
        }).resume()
    }
    
    func deleteGroupMember(memberToDelete: GroupMember) {
        
        let url = NSURL(string: baseUrlString +  "group_members/\(memberToDelete.id!.integerValue)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let response = response {
                
                let serverResponse = response as! NSHTTPURLResponse
                
                print("DELETE GROUP RESPONSE: \(serverResponse)")
                
                if error != nil {
                    
                    print("ERROR DELETING GROUP MEMBER \(memberToDelete.name): \(error)")
                    return
                }
                    
                else if serverResponse.statusCode >= 200 && serverResponse.statusCode < 300 {
                    
                    //group member was deleted from core data before this call.
                    print("GROUP MEMBER DELETED \(memberToDelete.name)")
                    
                }
            }
            else {
                
                print("no response deleting group")
            }
        })
        
        
        task.resume()

    }
}
