//
//  FCMockServer+.swift
//  FoodCollector
//
//  Created by Guy Freedman on 05/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    
    func sendFeedback(report: String) {
        
        //we are currently only registering the user. we should think of how to delete a registration. should it be through a delete service or add the registration message to this payload.
        
        let urlString = baseUrlString + "feedbacks"
        
        var params = [String : AnyObject]()
        
        params["reporter_name"]             = User.sharedInstance.userName
        params["report"]                    = report
        params["active_device_dev_uuid"]    = FCModel.sharedInstance.deviceUUID

        let dicToSend = ["feedback" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
        print(dicToSend)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)")
                
                guard let data = data else {return}
                let mydata = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                print("response data: \(mydata)")
                
                if error != nil {
                    print("error: \(error)")
                }
            }
        })
        
        task.resume()
        
    }

}