//
//  FCMockServer.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//
import CoreLocation
import UIKit

let reportActiveDeviceURL = "https://fd-server.herokuapp.com/active_devices.json"
let registerForPushNotificationsURL = "https://fd-server.herokuapp.com/active_devices/dev_uuid.json"
let getAllPublicationsURL = "https://fd-server.herokuapp.com/publications.json"

let reportArrivedToPublicationURL = ""
let reportsForPublicationBaseURL = "https://fd-server.herokuapp.com/publications/"
//<id>/reports.json?publication_version=<version>

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
    ///we don't use the old token
    public func reportDeviceTokenForPushWithDeviceNewToken(newtoken:String) {
        
        var params = [String: AnyObject]()
        params["is_ios"] = true
        params["dev_uuid"] = FCModel.sharedInstance.deviceUUID
        params["remote_notification_token"] = newtoken
        
        let jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        println(params)
        let devId = FCModel.sharedInstance.deviceUUID!
        let url = NSURL(string: registerForPushNotificationsURL)
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData!
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response: NSURLResponse!, error:NSError!) -> Void in
            
            let serverResponse = response as NSHTTPURLResponse
            print("respons: \(serverResponse.description)")
            println("status code: \(serverResponse.statusCode) ***************")
            
            if error != nil || serverResponse.statusCode != 200 {
                //we delete the key from UD so the app tries again in next launch
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidFailToRegisterPushNotificationKey)
                return
            }
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidFailToRegisterPushNotificationKey)
        })
        
        task.resume()
    }
    
    public func reportDeviceUUID(uuid: String) {
        println("device uuid: \(uuid)")
        
        let deviceId = uuid
        var remoteNotificationToken = NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey) as? String
        if remoteNotificationToken == nil {remoteNotificationToken = ""}
        let isIos = true
        let currentLatitude = FCModel.sharedInstance.userLocation.coordinate.latitude
        let curruntLongitude = FCModel.sharedInstance.userLocation.coordinate.longitude
        
        var params = NSMutableDictionary()
        
        params["dev_uuid"] = deviceId
        params["remote_notification_token"] = remoteNotificationToken
        params["is_ios"] = isIos
        params["last_location_latitude"] = currentLatitude
        params["last_location_longitude"] = curruntLongitude
        
        let jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        // println(params)
        let url = NSURL(string: reportActiveDeviceURL)
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response: NSURLResponse!, error:NSError!) -> Void in
            
            let serverResponse = response as NSHTTPURLResponse
            print("respons: \(serverResponse.description)")
            
            if error != nil || serverResponse.statusCode != 200 {
                //we delete the key from UD so the app tries again in next launch
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kDeviceUUIDKey)
                return
            }
        })
        
        task.resume()
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
        /*
        var publications = [FCPublication]()
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getAllPublicationsURL)
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
        
        let serverResponse = response as NSHTTPURLResponse
        print("response: \(serverResponse.description)")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        
        let arrayOfPublicationDicts = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [[String : AnyObject]]
        
        for publicationDict in arrayOfPublicationDicts {
        println("PUBLICATION DICT: \(publicationDict)")
        let publication = FCPublication.publicationWithParams(publicationDict)
        publications.append(publication)
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        completion(thePublications: pubs)
        })
        })
        })
        task.resume()
        */
    }
    
    ///
    /// fetch all reports to a certain Publication
    ///
    public func reportsForPublication(publication:FCPublication,completion:(success: Bool, reports: [FCOnSpotPublicationReport]?)->()) {

        var urlString = reportsForPublicationBaseURL + "\(publication.uniqueId)" + "/reports.json?publication_version=" + "\(publication.version)"
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
        
        var params = [String: AnyObject]()
        params["publication_id"] = publication.uniqueId
        params["publication_version"] = publication.version
        params["active_device_dev_uuid"] = FCModel.sharedInstance.deviceUUID
        params["date_of_report"] = report.date.timeIntervalSince1970
        params["report"] = report.onSpotPublicationReportMessage.rawValue
        
        
        let jsonData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        println(params)
        let url = NSURL(string: reportArrivedToPublicationURL) //TODO: insert the url string
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData!, response: NSURLResponse!, error:NSError!) -> Void in
            
            if var serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)")
                
                if error != nil || serverResponse.statusCode != 200 {
                    //we currently implement as best effort. nothing is done with an error
                }
            }
        })
        
        task.resume()
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
        report.date = endingDate
        pub6.reportsForPublication.append(report)
        
        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
        report.date = startingDate
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
