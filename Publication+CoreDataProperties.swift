//
//  Publication+CoreDataProperties.swift
//  FoodCollector
//
//  Created by Guy Freedman on 20/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Publication {

    @NSManaged var address: String?
    @NSManaged var audiance: NSNumber?
    @NSManaged var contactInfo: String?
    @NSManaged var didInformServer: NSNumber?
    @NSManaged var didModifyCoords: NSNumber?
    @NSManaged var didRecieveNewRegistration: NSNumber?
    @NSManaged var didRecieveNewReport: NSNumber?
    @NSManaged var didRegisterForCurrentPublication: NSNumber?
    @NSManaged var didTryToDownloadImage: NSNumber?
    @NSManaged var endingData: NSDate?
    @NSManaged var isOnAir: NSNumber?
    @NSManaged var isUserCreatedPublication: NSNumber?
    @NSManaged var latitude: NSDecimalNumber?
    @NSManaged var longitutde: NSDecimalNumber?
    @NSManaged var photoBinaryData: NSData?
    @NSManaged var publisherDevUUID: String?
    @NSManaged var publisherId: NSNumber?
    @NSManaged var publisherUserName: String?
    @NSManaged var startingData: NSDate?
    @NSManaged var subtitle: String?
    @NSManaged var title: String?
    @NSManaged var typeOfCollecting: NSNumber?
    @NSManaged var uniqueId: NSNumber?
    @NSManaged var version: NSNumber?
    @NSManaged var storedDistanceFromUserLocation: NSNumber!
    @NSManaged var registrations: NSSet?
    @NSManaged var reports: NSSet?

}
