//
//  CDPublicationRegistrationFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 28/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData

protocol FCPublicationRegistrationsFetcherDelegate: NSObjectProtocol {
    func didFinishFetchingPublicationRegistrations()
}

let kPublicationRegistrationUniqueIdKey             = "id"
let kPublicationRegistrationPublicationIdKey        = "publication_id"
let kPublicationRegistrationPublicationVersionKey   = "publication_version"
let kPublicationRegistrationContactInfoKey          = "collector_contact_info"
let kPublicationRegistrationCollectorNameKey        = "collector_name"
let kPublicationRegistrationDateOfRegistrationKey   = "date_of_registration"



class CDPublicationRegistrationFetcher: NSObject {
    
    
    //Fetcher delegate is set only when PublicationDetailsVC initiates
    //the fetch. must check if it's nill
    
    weak var delegate: FCPublicationRegistrationsFetcherDelegate?
    
    init(publication: Publication, context: NSManagedObjectContext) {
        self.publication = publication
        self.context     = context
        super.init()
    }
    
    var publication :Publication
    var context     :NSManagedObjectContext

    func fetchRegistrationsForPublication(markNew: Bool) {
        
        let publication = self.publication
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getPublicationWithIdentifierURL + "\(publication.uniqueId!)/registered_user_for_publications")
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response  {
                let aServerResponse = serverResponse as! NSHTTPURLResponse
                print("response: \(serverResponse.description)", terminator: "")
                
                
                if error == nil && aServerResponse.statusCode < 300{
                    
                    let registrationsArrayofDicts = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? [[String : AnyObject]]
                    
                    if let registrations = registrationsArrayofDicts {
                        
                        print("registrations: \(registrations)", terminator: "=====end registration=====")
                        
                        self.context.performBlock({ () -> Void in
                          
                            //if this is initiated by initial web fetch, we check if we should present a new registration notification
                            if markNew && self.publication.didRegisterForCurrentPublication!.boolValue && self.publication.registrations?.count < registrations.count {
                                
                                publication.didRecieveNewRegistration = true
                            }
                            
                            self.processRegistrationsJsonArray(registrations)
                            
                            //informs publicationDetails to update registrations counter
                            //we might need to add Publications Table View as a listener
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                let userInfo = ["publication" : self.publication]
                                NSNotificationCenter.defaultCenter().postNotificationName(kRecievedPublicationRegistrationNotification, object: self, userInfo: userInfo)
                                if let delegate = self.delegate {
                                    delegate.didFinishFetchingPublicationRegistrations()
                                }
                            })
                        })
                    }
                }
            }
        })
        task.resume()
    }
    
    private func processRegistrationsJsonArray(params: [[String: AnyObject]]) {
       
        
        for registrationDict in params {
            print(registrationDict, separator: "================", terminator: "=======END=======")
            print("\n")
            
            
            let id                      = registrationDict[kPublicationRegistrationUniqueIdKey]             as? Int ?? 0
            
            let request = NSFetchRequest(entityName: "PublicationRegistration")
            let predicate = NSPredicate(format: "id = %@", NSNumber(integer: id))
            request.predicate = predicate
    
            var results: [PublicationRegistration]?
            do {
                results = try context.executeFetchRequest(request) as? [PublicationRegistration]
            } catch {
                print("error fetching registration on CDPublicationRegitrationFetcher \(error)")
            }
            
            guard let theResults = results else {return}
            
            if theResults.count == 0 {
                
                //create new
                let publicationId           = registrationDict[kPublicationRegistrationPublicationIdKey]        as? Int ?? 0
                let publicationVersion      = registrationDict[kPublicationRegistrationPublicationVersionKey]   as? Int ?? 0
                var collectorName           = registrationDict[kPublicationRegistrationCollectorNameKey]        as? String ?? ""
                collectorName = collectorName == "" ? NSLocalizedString("User", comment:"") : collectorName
                let collectorContactInfo    = registrationDict[kPublicationRegistrationContactInfoKey]          as? String ?? "" //"Unavilable"
                let dateDouble              = registrationDict[kPublicationRegistrationDateOfRegistrationKey]   as? Double ?? NSDate().timeIntervalSince1970
                let dateOfRegistration      = NSDate(timeIntervalSince1970: dateDouble)
                let activeDevice            = registrationDict["active_device_dev_uuid"] as? String ?? ""
                let collectorUserId         = registrationDict["collector_user_id"] as? Int ?? 0
                
                self.context.performBlockAndWait({ () -> Void in
                    
               
                
                
                let registration = NSEntityDescription.insertNewObjectForEntityForName("PublicationRegistration", inManagedObjectContext: self.context) as? PublicationRegistration
                
                if let newRegistration = registration {
                
                    newRegistration.activeDeviceUUID        = activeDevice
                    newRegistration.collectorContactInfo    = collectorContactInfo
                    newRegistration.collectorName           = collectorName
                    newRegistration.collectorUserId         = collectorUserId
                    newRegistration.dateOfRegistration      = dateOfRegistration
                    newRegistration.id                      = id
                    newRegistration.publicationId           = publicationId
                    newRegistration.publicationVersion      = publicationVersion
                    newRegistration.publication             = self.publication
                    
                    if self.publication.registrations == nil {self.publication.registrations = Set<PublicationRegistration>()}
                    self.publication.registrations = self.publication.registrations?.setByAddingObject(newRegistration)
                    
      
                    //we only add new report log from web fetch and not for the User's report
                    
                    if self.publication.didRegisterForCurrentPublication?.boolValue == true {
                   
                        let newRegistrationLog = ActivityLog.LogType.Registration.rawValue
                        ActivityLog.activityLog(self.publication, type: newRegistrationLog, context: self.context)
                    }
                    
                    do {
                        try self.context.save()
                    } catch {
                        
                        print("error saving local context in CDPublicationRegistrationFetcher \(error)")
                    }
                }
            })

            }
        }
    }
    

}
