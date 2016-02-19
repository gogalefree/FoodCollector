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
     
      //TODO: Implement with fdserver
        var groupData = groupData
        groupData.id = 1
        
        
        
        completion(success: true, groupData: groupData)
        
        
        /*
                
        guard let data = Group.groupJsonWithGroupData(groupData) else {return}
        
        //TODO: Change the url
        let url = NSURL(string: baseUrlString + ".json")
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
                
                //parse params
                //set the group id in the group data object
                completion(success: true, groupData: groupData)
            }
                
            else {
                
                print("group post to server failed with error code \(response.statusCode)")
                completion(success: false, groupData: groupData)
                return
            }
            
        }).resume()

    */
    }
}