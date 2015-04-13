//
//  FCServerProtocol.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import CoreLocation
import Foundation
import UIKit

protocol FCServerProtocol {
    
    
    
    ///
    /// reports device token to our server to use for APNS.
    /// old token can be nil (for the first report).
    ///
    func reportDeviceTokenForPushWithDeviceNewToken(newtoken:String)
    
    func reportDeviceUUID(uuid: String)
    
    
    ///
    /// reports the user’s last known location. the server uses this information
    ///  to send push notification of a new Publication with defined radius.
    /// called at launch & before the app goes to background mode.
    ///
    func reportUserLocation()
    
    ///
    /// fetch all publications from server.
    ///
    func downloadAllPublicationsWithCompletion(completion: (thePublications: [FCPublication]) -> Void)
    
    ///
    /// fetch publication with a certain identifier
    /// called after a newPublication push notification had arrived.
    func fetchPublicationWithIdentifier(identifier: PublicationIdentifier ,completion: (publication: FCPublication) -> Void)

    
    ///
    /// fetch all reports to a certain Publication
    ///
    func reportsForPublication(publication:FCPublication,completion:(success: Bool, reports: [FCOnSpotPublicationReport]?)->())
    
    ///
    /// reports a Report of a Publication by a user that arrived at a publication
    ///  spot
    ///
    func reportArrivedPublication(publication: FCPublication,withReport report:FCOnSpotPublicationReport)
    
    ///
    /// informs the server that a user deleted his publication
    ///
    func takePublicationOffAir(publication: FCPublication, completion: (success:Bool)->Void)
    
    ///
    /// post a new Publication to the server
    ///
    func postNewCreatedPublication(params:[String:AnyObject], completion:(success: Bool, uniqueID: Int, version: Int)->())
    
    ///
    /// post an edited Publication to the server. the publication must be expired or taken off air before
    ///
    func postEditedPublication(params:[String:AnyObject],publication: FCPublication, completion:(success: Bool,  version: Int)->())
   
    ///
    /// register or unregister the current user to a publication
    func registerUserForPublication(publication: FCPublication, message: FCRegistrationForPublication.RegistrationMessage)
    
}

