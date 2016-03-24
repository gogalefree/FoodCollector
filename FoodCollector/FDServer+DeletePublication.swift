//
//  FDServer+DeletePublication.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension FCMockServer {
    
    func deletePublication(publication: Publication, completion: (success: Bool) -> ()) {
        
        let publicationUniqueID = publication.uniqueId!.integerValue
        
        let url = NSURL(string: deletePublicationURL + "\(publicationUniqueID)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let response = response {
                let serverResponse = response as! NSHTTPURLResponse
                
                print("DELETE PUBLICATION RESPONSE: \(serverResponse)")
                
                if error != nil || serverResponse.statusCode > 300 {
                    
                    print("ERROR DELETING: \(error)")
                    completion(success: false)
                } else  {
                    completion(success: true)
                }
            }
            else {
                completion(success: false)
            }
        })
        
        
        task.resume()
    }

}