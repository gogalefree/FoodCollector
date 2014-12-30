//
//  FCMockServer.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//
import CoreLocation
import UIKit

public class FCMockServer: NSObject , FCServerProtocol {
    
    ///
    /// receives coordinate fro specified address
    ///
    public func googleGeoCodeForAddress(address:String)->CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    ///
    /// reports device token to our server to use for APNS.
    /// old token can be nil (for the first report).
    ///
    public func reportDeviceTokenForPushWithDeviceNewToken(newtoken:String, oldtoken:String?) {
        println("new token \(newtoken)")
        if let currentToken = oldtoken {
            println("old token \(currentToken)")
        }
    }
    
    public func reportDeviceUUID(uuid: String) {
        println("device uuid: \(uuid)")
    }
    
    
    ///
    /// downloads an Image for Publication. must be implemented async.
    ///
    public func imageForPublication(aPublication: FCPublication)->UIImage {
        return UIImage()
    }
    
    ///
    /// reports the user’s last known location. the server uses this information
    ///  to send push notification of a new Publication with defined radius.
    /// called at launch & before the app goes to background mode.
    ///
    public func reportUserLocation(location:CLLocation) {
        
    }
    
    ///
    /// fetch all publications from server.
    ///
    public func downloadAllPublicationsWithCompletion(completion:(thePublications: [FCPublication]) -> Void){
        
        let pubs = self.makePublication()
        completion(thePublications: pubs)
        
    }
    
    ///
    /// fetch all reports to a certain Publication
    ///
    public func reportsForPublication(publication:FCPublication,completion:(success: Bool, reports: [FCOnSpotPublicationReport])->()) {
        
    }
    
    ///
    /// reports a Report of a Publication by a user that arrived at a publication
    ///  spot
    ///
    public func reportArrivedPublication(publication: FCPublication,withReport report:FCOnSpotPublicationReport) {
        
    }
    
    ///
    /// informs the server that a user deleted his publication
    ///
    public func deletePublication(publication:FCPublication) {
        
    }
    
    ///
    /// post a new Publication to the server
    ///
    public func postPublication(publication:FCPublication, completion:(success: Bool, uniqueID: Int)->()) {
        
    }
    
    ///
    /// search for address with google location autocomplete api
    ///
    public func googleLocationAddressesWithKeyWord(searchString:String, completion:(success: Bool, results: [String])->()) {
        
    }
    
    
}

public extension FCMockServer {
    
    public func makePublication () -> [FCPublication] {
        
        var publicaions = [FCPublication]()
        var uniqueId = 111111
        var title = "Green Apples"
        var subtitle = "Fresh small green apples"
        var address = "hod hasharon"
        var typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        var coordinate = CLLocationCoordinate2D(latitude: 32.361233, longitude: 34.867452)
        var startingDate = NSDate()
        var endingDate = NSDate(timeIntervalSinceNow: 129600)
        var contactInfo = "call: 0522222222"
        var photoUrl = "www.url.com"
        var version = 2
        
        let pub1 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub1.countOfRegisteredUsers = 2
        publicaions.append(pub1)
        
        uniqueId = 2222222
        title = "50 k\"g of sweet BBQ chicken wings"
        subtitle = "Chicken wings are not frozen!!!! please be quick about it!"
        address = "beit halevi"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.357868, longitude: 34.934164)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: -360000)
        photoUrl = "www.guy.com"
        version = 1
        
        let pub2 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,contactInfo: nil, subTitle: subtitle, version: version)
        pub2.countOfRegisteredUsers = 4
        publicaions.append(pub2 )
        
        
        uniqueId = 3333333
        title = "35 assorted dishes"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.381214, longitude: 34.882611)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: -345600)
        photoUrl = "www.denis.com"
        version = 1
        
        let pub3 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub3.countOfRegisteredUsers = 6
        publicaions.append(pub3)
        
        uniqueId = 444444
        title = "45 assorted dishes"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.232116, longitude: 34.869232)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        version = 1
        
        let pub4 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub4.countOfRegisteredUsers = 4
        publicaions.append(pub4)
        
        uniqueId = 555555
        title = "55 humus plates"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.357870, longitude: 35.034170)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.maayan.com"
        version = 1
        
        let pub5 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: nil, subTitle: subtitle, version: version)
        pub4.countOfRegisteredUsers = 4
        publicaions.append(pub5)
        
        uniqueId = 666666
        title = "65 avucado sandwiches"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.140298, longitude: 34.848289)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: -266000)
        photoUrl = "www.denis.com"
        version = 1
        
        let pub6 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub6.countOfRegisteredUsers = 6
        publicaions.append(pub6)
        
        uniqueId = 777777
        title = "75 soup dishes"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.268120, longitude: 34.867516)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        version = 1
        
        let pub7 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: nil, subTitle: subtitle, version: version)
        pub7.countOfRegisteredUsers = 10
        publicaions.append(pub7)
        
        uniqueId = 888888
        title = "85 assorted dishes"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.277409, longitude: 34.883995)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        
        
        let pub8 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: nil, subTitle: subtitle, version: version)
        pub8.countOfRegisteredUsers = 3
        publicaions.append(pub8)
        
        uniqueId = 999999
        title = "95 assorted dishes"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.296855, longitude: 34.914207)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        
        let pub9 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub9.countOfRegisteredUsers = 0
        publicaions.append(pub9)
        
        uniqueId = 101010
        title = "105 assorted dishes"
        subtitle = "first and main courses in plastick boxes"
        address = "Tel Aviv"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.318038, longitude: 34.857559)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        
        let pub10 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub10.countOfRegisteredUsers = 1
        publicaions.append(pub10)
        
        return publicaions
    }
}
