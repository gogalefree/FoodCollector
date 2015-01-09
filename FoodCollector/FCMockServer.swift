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
    public func reportsForPublication(publication:FCPublication,completion:(success: Bool, reports: [FCOnSpotPublicationReport]?)->()) {
        //download
        //parse
        //pass to the completion handler
    }
    
    func registerUserForPublication(publication: FCPublication, message: FCRegistrationForPublication.RegistrationMessage) {
        
    }
    
    ///
    /// reports a Report of a Publication by a user that arrived at a publication
    ///  spot
    ///
    public func reportArrivedPublication(publication: FCPublication,withReport report:FCOnSpotPublicationReport) {
        println("report to server: \(report.onSpotPublicationReportMessage) for publication title: \(publication.title)")
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
        var title = "תפוחים ירוקים מהעץ"
        var subtitle = "השארתי על הגדר מחוץ לבית"
        var address = "רחוב שדרות בנימין 16, הוד השרון"
        var typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        var coordinate = CLLocationCoordinate2D(latitude: 32.361233, longitude: 34.867452)
        var startingDate = NSDate()
        var endingDate = NSDate(timeIntervalSinceNow: 129600)
        var contactInfo = "0544448246"
        var photoUrl = "www.url.com"
        var version = 2
        
        let pub1 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub1.countOfRegisteredUsers = 2
        var report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage.HasMore, date: startingDate)
        pub1.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
        pub1.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
        pub1.reportsForPublication.append(report)

        publicaions.append(pub1)
        
        uniqueId = 2222222
        title = "50 קג עוף צלוי"
        subtitle = "כנפי עוף שהופשרו אתמול. נא להזדרז!"
        address = "מושב בית הלוי"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.357868, longitude: 34.934164)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: -360000)
        photoUrl = "www.guy.com"
        version = 1
        
        let pub2 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub2.countOfRegisteredUsers = 4
        
        report.date = endingDate
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub2.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub2.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub2.reportsForPublication.append(report)
        publicaions.append(pub2 )
        
        
        uniqueId = 3333333
        title = "35 מנות מוכנות"
        subtitle = "מנות ראשונות ומנות עיקריות בקופסאות פלסטיק"
        address = "רופין 19 תל אביב"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.381214, longitude: 34.882611)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: -345600)
        contactInfo = "0544448246"
        photoUrl = "www.denis.com"
        version = 1
        
        let pub3 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub3.countOfRegisteredUsers = 6
        report.date = endingDate
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub3.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub3.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
        pub3.reportsForPublication.append(report)

        publicaions.append(pub3)
        
        uniqueId = 444444
        title = "צלי בקר ממסיבת חתונה"
        subtitle = "5 ק״ג אנטריקוט"
        address = "טשרנחובסקי 5 רעננה"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.357622, longitude: 34.908564)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
                version = 1
        
        let pub4 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub4.countOfRegisteredUsers = 4
        report.date = endingDate
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub4.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub4.reportsForPublication.append(report)
        publicaions.append(pub4)
        
        uniqueId = 555555
        title = "55 מנות חומוס"
        subtitle = "חומוס עוזי המקורי!"
        address = "רחוב שער העמק 17 נתניה"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.350807, longitude: 34.908221)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.maayan.com"
        version = 1
        
        let pub5 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub4.countOfRegisteredUsers = 4
        report.date = startingDate
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub5.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
        pub5.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
        pub5.reportsForPublication.append(report)

        publicaions.append(pub5)
        
        uniqueId = 666666
        title = "סנדביץ׳ אבוקדו"
        subtitle = "נשאר בקפיטריה של אוניברסיטת תל אביב"
        address = "רחוב איינשטיין תל אביב"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.140298, longitude: 34.848289)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: -266000)
        photoUrl = "www.denis.com"
        version = 1
        
        let pub6 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
        pub6.countOfRegisteredUsers = 6
        report.date = startingDate
        
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
        pub6.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
        pub6.reportsForPublication.append(report)
        publicaions.append(pub6)
        
        uniqueId = 777777
        title = "מרק חם"
        subtitle = "75 מנות מרק עוף טרי"
        address = "כיכר העצמאות נתניה"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.349792, longitude: 34.880111)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        version = 1
        
        let pub7 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub7.countOfRegisteredUsers = 10
        
        report.date = startingDate
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub7.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub7.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
        pub7.reportsForPublication.append(report)
        publicaions.append(pub7)
        
        uniqueId = 888888
        title = "10 מנות פלאפל"
        subtitle = "פלאפל התחנה"
        address = "מחלף נתניה"
        typeOfCollecting = FCTypeOfCollecting.FreePickUp
        coordinate = CLLocationCoordinate2D(latitude: 32.277409, longitude: 34.883995)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        
        
        let pub8 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: nil, subTitle: subtitle, version: version)
        pub8.countOfRegisteredUsers = 3
        report.date = startingDate
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub8.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
        pub8.reportsForPublication.append(report)
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
        pub8.reportsForPublication.append(report)
        publicaions.append(pub8)
        
        uniqueId = 999999
        title = "חמוצים בייתיים"
        subtitle = "ךימון כבוש, זייתים ירוקים"
        address = "רחוב המעלות 2 כפר יונה"
        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
        coordinate = CLLocationCoordinate2D(latitude: 32.296855, longitude: 34.914207)
        startingDate = NSDate()
        endingDate = NSDate(timeIntervalSinceNow: 266000)
        photoUrl = "www.denis.com"
        
        let pub9 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
        pub9.countOfRegisteredUsers = 0
        publicaions.append(pub9)
        
        uniqueId = 101010
        title = "מוקפץ תאילנדי"
        subtitle = "2 ק״ג מוקפץ חם וטרי"
        address = "קניון השרון נתניה, קומה א׳"
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
