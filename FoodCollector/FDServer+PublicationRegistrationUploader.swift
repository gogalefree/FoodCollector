//
//  FDServer+PublicationRegistrationUploader.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    func registerUserForPublication(registration: PublicationRegistration, completion: (success:Bool) -> Void) {
        
        
        let id = registration.publication!.uniqueId!.integerValue
        let urlString = reportsForPublicationBaseURL + "\(id)/registered_user_for_publications.json"
    
        var params = [String : AnyObject]()
        params["publication_id"] = id
        params["publication_version"] = registration.publicationVersion!.integerValue
        params["date_of_registration"] = registration.dateOfRegistration!.timeIntervalSince1970
        params["active_device_dev_uuid"] = FCModel.sharedInstance.deviceUUID
        params[kPublicationRegistrationContactInfoKey] = registration.collectorContactInfo!
        params[kPublicationRegistrationCollectorNameKey] = registration.collectorName!
        params["collector_user_id"] = registration.collectorUserId!.integerValue
    
        
        
        
        let dicToSend = ["registered_user_for_publication" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
        print("registration to send: \(dicToSend)" + __FUNCTION__)
        
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
                
                if error != nil || serverResponse.statusCode > 300 {
                    //we currently implement as best effort. nothing is done with an error
                    completion(success: false)
                    return
                }
                
                if let data = data {
                    
                    
                    
                    do {
                       //TODO check if the id is okay
                        let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
                        guard let registrationDict = dict else {return}
                        registration.managedObjectContext?.performBlock({ () -> Void in
                            
                            registration.id = registrationDict["id"] as? Int ?? 0
                            completion(success: true)
                        })
                        
                    } catch {
                        print("error parsing post registration response data \(error)")
                        completion(success: false)

                    }
                }
                else {
                    completion(success: false)
                }
            }
        })
        
        task.resume()

    }
    
    func unRegisterUserFromComingToPickUpPublication(publication: Publication, completion: (success: Bool) -> Void) {
        
        let uniqueId = publication.uniqueId!.integerValue
        let publicationVersion = publication.version!.integerValue
        let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}-").invertedSet
        let deviceUUID = FCModel.sharedInstance.deviceUUID!.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!

        let uuid = deviceUUID ?? ""
        print("uuid escaped: \(uuid)")
        
        
        let url = NSURL(string: unRegisterUserFromPublicationURL + "\(uniqueId)" + "/registered_user_for_publications/1?publication_version=\(publicationVersion)&active_device_dev_uuid=\(uuid)")
        print("url: \(url)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)", terminator: "")
                if error != nil || serverResponse.statusCode > 300 {
                    //we currently implement as best effort. nothing is done with an error
                    print("Unregister for publication error: \(error)")
                    completion(success: false)
                    
                }
                
                else {
                    completion(success: true)
                }
            }
        })
        task.resume()
    }

}