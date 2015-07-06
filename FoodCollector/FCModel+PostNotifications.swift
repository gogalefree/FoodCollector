//
//  FCModel+PostNotifications.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

extension FCModel {
    
    ///posts NSNotification when the downloaded data is ready
    func postFetchedDataReadyNotification () {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecievedNewDataNotification, object: self)
    }
    
    //posts after the new publication recived from push was added to the model
    func postRecievedNewPublicationNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecievedNewPublicationNotification, object: self)
    }
    
    //posts after the deleted publication from push was removed from the model
    func postDeletedPublicationNotification(publicationIdentifier: PublicationIdentifier) {
        NSNotificationCenter.defaultCenter().postNotificationName(kDeletedPublicationNotification, object: self)
    }
    
    func postRecivedPublicationReportNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kRecivedPublicationReportNotification, object: self)
    }
    
    func postRecivedPublicationRegistrationNotification(publication:FCPublication) {
        let userInfo = ["publication" : publication]
        NSNotificationCenter.defaultCenter().postNotificationName(kRecievedPublicationRegistrationNotification, object: self, userInfo: userInfo)
    }
    
    func postNewUserCreatedPublicationNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(kNewUserCreatedPublicationNotification, object: self)
    }
    
    func postDeleteOldVersionOfUserCreatedPublications() {
        NSNotificationCenter.defaultCenter().postNotificationName(kDidDeleteOldVersionsOfUserCreatedPublication, object: self)
        
    }
}