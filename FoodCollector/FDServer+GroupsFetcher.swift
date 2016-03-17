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
                    
                    let arrayOfGroups = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String : AnyObject]]
                        
                    
                    if let groupsArray = arrayOfGroups {
                            
                        for groupParams in groupsArray {
                            print("group:\n\(groupParams.description)")
                            
                            Group.instatiateGroupWithParams(groupParams, context: context)
                        }
                    }
                    
                }
                
            }
        })
        task.resume()
        
    }
    
    
}