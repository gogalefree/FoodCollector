//
//  PublicationRegistration.swift
//  FoodCollector
//
//  Created by Guy Freedman on 27/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData


class PublicationRegistration: NSManagedObject {


    class func registrationForPublication(publication: Publication, context: NSManagedObjectContext) -> PublicationRegistration?
    {
        
        var aRegistration: PublicationRegistration? = nil
        let newRegistration = NSEntityDescription.insertNewObjectForEntityForName("PublicationRegistration", inManagedObjectContext: context) as? PublicationRegistration
        
        if let registration = newRegistration {
            
            registration.activeDeviceUUID = FCModel.sharedInstance.deviceUUID
            registration.collectorContactInfo = User.sharedInstance.userPhoneNumber
            registration.collectorContactInfo = User.sharedInstance.userIdentityProviderUserName
            registration.collectorUserId = User.sharedInstance.userUniqueID
            registration.dateOfRegistration = NSDate()
            registration.publicationId = publication.uniqueId
            registration.publicationVersion = publication.version
            registration.publication = publication
            
            publication.registrations = publication.registrations?.setByAddingObject(registration)
            
            aRegistration = registration
            
        }

        return aRegistration
    }
}
