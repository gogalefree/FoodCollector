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
    
    init(publication: FCPublication) {
        self.publication = publication
        super.init()
    }

    var publication: FCPublication
    

    
    
    
    
    func fetchPublicationRegistration(checkNew: Bool) {
        
        let publication = self.publication
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getPublicationWithIdentifierURL + "\(publication.uniqueId)/registered_user_for_publications")
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response  {
                let aServerResponse = serverResponse as! NSHTTPURLResponse
                print("response: \(serverResponse.description)", terminator: "")
                
                
                if error == nil && aServerResponse.statusCode == 200{
                    
                    let registrationsArrayofDicts = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? [[String : AnyObject]]
                    
                    if let registrations = registrationsArrayofDicts {
                        
                        //if this is initiated by initial web fetch, we check if we should present a new registration notification
                        if checkNew && self.publication.didRegisterForCurrentPublication && self.publication.countOfRegisteredUsers < registrations.count {self.publication.didRecieveNewRegistration = true}
                        
                        self.publication.countOfRegisteredUsers = registrations.count
                        self.updateUserCreatedPublicationForPublication(publication)
                        
                        if let delegate = self.delegate {
                            delegate.didFinishFetchingPublicationRegistrations()
                        }
                    }
                }
            }
        })
        task.resume()
    }
    
    func updateUserCreatedPublicationForPublication(publication: FCPublication) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        
        let userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
        
            for userCreatedPublication in userCreatedPublications {
            
                if publication.uniqueId == userCreatedPublication.uniqueId &&
                
                    publication.version == userCreatedPublication.version {
                    userCreatedPublication.countOfRegisteredUsers = publication.countOfRegisteredUsers
                    break
                }
            }
       })
    }
}
