//
//  FDServer+GroupsFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 03/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    
    func fetchGroupsForUser(contecxt: NSManagedObjectContext) {
        
        //TODO: Change url
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "https://ofer-fd-server.herokuapp.com/users/21/groups")
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse  {
                
                print("response: \(serverResponse.description)", terminator: "")
                
             
                if error != nil || serverResponse.statusCode > 300 {
                    //handle error
                    return
                }
                
                if let data = data {
                    
                    let arrayOfGroups = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String : AnyObject]]
                        
                    
                    if let groupsArray = arrayOfGroups {
                            
                        for groupParams in groupsArray {
                            print("group:\n\(groupParams.description)")
                            
                            let groupAdminId = groupParams["user_id"] as? Int ?? 0
                            let groupId = groupParams["group_id"] as? Int ?? 0
                            let groupName = groupParams["group_name"] as? String ?? ""
                            let membersArray = groupParams["members"] as? [[String : AnyObject]]
                            
                            if let membersParams = membersArray {
                                
                                for member in membersParams {
                                    
                                    let memberGroupId = member["Group_id"] as? Int ?? 0
                                    let memberId = member["id"] as? Int ?? 0
                                    let isAdimn = member["is_admin"] as? Int ?? 0
                                    let memberName = member["name"] as? String ?? ""
                                    let memberPhoneNumber = member["phone_number"] as? String ?? ""
                                    let memberUserId = member["user_id"] as? Int ?? 0
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
        })
        task.resume()
        
    }
    
    
}