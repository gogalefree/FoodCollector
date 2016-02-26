//
//  FDServer+Groups.swift
//  FoodCollector
//
//  Created by Guy Freedman on 17/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    func postGroup(groupData: GroupData, completion: (success: Bool, groupData: GroupData?) -> Void) {
     
        var groupData = groupData
        guard let data = Group.groupJsonWithGroupData(groupData) else {return}
        
        //TODO: Change the url
        let url = NSURL(string: /*baseUrlString*/  "https://ofer-fd-server.herokuapp.com/groups.json")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod  = "POST"
        request.HTTPBody    = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            taskData, response, error -> () in
            
            if error != nil {
                
                completion(success: false, groupData: groupData)
                return
            }
            
            guard let response = response as? NSHTTPURLResponse , incomingData = taskData else {completion(success: false, groupData: groupData) ; return}
            
            print("response: \(response)")
            if response.statusCode == 200 || response.statusCode == 201 {
                
                let responseParams = try? NSJSONSerialization.JSONObjectWithData(incomingData, options: [])
                guard let params = responseParams else {completion(success: false, groupData: groupData) ; return}
                print("params: \(params)")
                let possibleId = params["id"] as? Int
                if let id = possibleId {
                    groupData.id = id
                    completion(success: true, groupData: groupData)
                }
                else {
                    //no valid id means failiure
                    completion(success: false, groupData: groupData)

                }
            }
                
            else {
                
                print("group post to server failed with error code \(response.statusCode)")
                completion(success: false, groupData: groupData)
                return
            }
            
        }).resume()
    }
    
    func deleteGroup(groupToDelete: Group) {
        
        //TODO: Change the url
        let url = NSURL(string: /*baseUrlString*/  "https://ofer-fd-server.herokuapp.com/groups/\(groupToDelete.id!.integerValue)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let response = response {
                
                let serverResponse = response as! NSHTTPURLResponse
                
                print("DELETE GROUP RESPONSE: \(serverResponse)")
                
                if error != nil || serverResponse.statusCode != 200 {
                    
                    print("ERROR DELETING GROUP: \(error)")
                    return
                }
                
                else if serverResponse.statusCode >= 200 && serverResponse.statusCode < 300 {
                    
                    //group was deleted from server.
                    //delete from core data
                    //group members are deleted automatically

                                   }
            }
            else {

                print("no response deleting group")
            }
        })
        
        
        task.resume()
    }

    
}