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
    /// receives coordinate fro specified address
    ///
    func googleGeoCodeForAddress(address:String)->CLLocationCoordinate2D
    
    ///
    /// reports device token to our server to use for APNS.
    /// old token can be nil (for the first report).
    ///
    func reportDeviceTokenForPushWithDeviceNewToken(newtoken:String, oldtoken:String?)
    
    func reportDeviceUUID(uuid: String)
    
    ///
    /// downloads an Image for Publication. must be implemented async.
    ///
    func imageForPublication(aPublication: FCPublication)->UIImage
    
    ///
    /// reports the user’s last known location. the server uses this information
    ///  to send push notification of a new Publication with defined radius.
    /// called at launch & before the app goes to background mode.
    ///
    func reportUserLocation(location:CLLocation)
    
    ///
    /// fetch all publications from server.
    ///
    func downloadAllPublicationsWithCompletion(completion: (thePublications: [FCPublication]) -> Void)
    
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
    func deletePublication(publication:FCPublication)
    
    ///
    /// post a new Publication to the server
    ///
    func postPublication(publication:FCPublication, completion:(success: Bool, uniqueID: Int)->())
    
    ///
    /// search for address with google location autocomplete api
    ///
    func googleLocationAddressesWithKeyWord(searchString:String, completion:(success: Bool, results: [String])->())
    
    ///
    /// register or unregister the current user to a publication
    func registerUserForPublication(publication: FCPublication, message: FCRegistrationForPublication.RegistrationMessage)
    
}

