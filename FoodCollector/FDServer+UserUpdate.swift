//
//  FDServer+UserUpdate.swift
//  FoodCollector
//
//  Created by Guy Freedman on 22/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {

    
    func updateUserProfile(completion: (success: Bool) -> Void) {
    
        let params = [
            indentityProviderKey            : User.sharedInstance.userIdentityProvider,
            identityProviderUserIdKey       : User.sharedInstance.userIdentityProviderUserID,
    //        identityProviderTokenKey        : User.sharedInstance.userIdentityProviderToken,
            phoneNumberKey                  : User.sharedInstance.userPhoneNumber,
            identityProviderEmailKey        : User.sharedInstance.userIdentityProviderEmail,
         //   identityProviderUserNameKey     : User.sharedInstance.userIdentityProviderUserName,
            isLoggedInKey                   : true,
            activeDeviceDevUuidKey          : FCModel.sharedInstance.deviceUUID!]
        let userDict = [userKey : params]

        print("user dict to send:\n\(userDict)")
        
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(userDict, options: [])
        let urlString = baseUrlString + "users/\(User.sharedInstance.userUniqueID)"
        let url = NSURL(string: urlString)
        print("user update url:\n\(url)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request,
                                               completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
                                                
                                                if let serverResponse = response as? NSHTTPURLResponse {
                                                    print("post edited user profile response: \(serverResponse)")
                                                    if error == nil && serverResponse.statusCode < 300 {
                                                        if let data = data {
                                                            let dict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                                                            if let dict = dict {
                                                                print("dic recived: \(dict)")
                                                            }
                                                        }
                                                        completion(success: true)

                                                    }
                                                    else {
                                                        completion(success: false)
                                                    }
                                                }
        })
        
        task.resume()

    }
}