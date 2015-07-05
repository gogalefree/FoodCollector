//
//  FCPublicationRegistrationsFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/6/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

protocol FCPublicationRegistrationsFetcherDelegate: NSObjectProtocol {
    func didFinishFetchingPublicationRegistrations()
}


class FCPublicationRegistrationsFetcher: NSObject {
    
    //Fetcher delegate is defined only when PublicationDetailsVC initiates
    //the fetching. must check if it's nill
    
    weak var delegate: FCPublicationRegistrationsFetcherDelegate?

    
    var publication: FCPublication! {
        didSet {
            if let publication = publication {
                fetchPublicationRegistration(publication)
            }
        }
    }
    
    
    
    
    func fetchPublicationRegistration(publication: FCPublication) {
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getPublicationWithIdentifierURL + "\(publication.uniqueId)/registered_user_for_publications")
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if let serverResponse = response  {
                var aServerResponse = serverResponse as! NSHTTPURLResponse
                print("response: \(serverResponse.description)")
                
                
                if error == nil && aServerResponse.statusCode == 200{
                    
                    let registrationsArrayofDicts = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [[String : AnyObject]]
                    
                    if let registrations = registrationsArrayofDicts {
                        
                        self.publication.countOfRegisteredUsers = registrations.count
                        
                        if let delegate = self.delegate {
                            delegate.didFinishFetchingPublicationRegistrations()
                        }
                    }
                }
            }
        })
        task.resume()
    }
    
}
