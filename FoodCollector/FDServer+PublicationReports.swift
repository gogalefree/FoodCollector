//
//  FDServer+PublicationReports.swift
//  FoodCollector
//
//  Created by Guy Freedman on 27/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData

extension FCMockServer {
    
    func reportsForPublication(publication:Publication,
        context: NSManagedObjectContext,
        completion: (success: Bool) -> Void ){
            
            let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId!.integerValue)" + "/publication_reports.json?publication_version=" + "\(publication.version!.integerValue)"
        
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: urlString)
            let task = session.dataTaskWithURL(url!, completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let theResponse = response {
                    
                    let serverResponse = theResponse as! NSHTTPURLResponse
                    
                    if error == nil && serverResponse.statusCode == 200 {
                        if let data = data {

                            
                                
                                let arrayOfReports = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String : AnyObject]]
                                
                                if let arrayOfReports = arrayOfReports {
                                    
                                    PublicationReport.reportsFromWebFetchForPublication(publication, arrayOfDicts: arrayOfReports, context: context)
                                    completion(success: true)
                                    
                                }
                            
                        }
                    }
                    else {
                        completion(success: false)
                    }
                }
                
            })
            task.resume()
    }

}