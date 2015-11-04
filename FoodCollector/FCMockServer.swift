//
//  FCMockServer.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//
import CoreLocation
import UIKit

let baseUrlString = FCModel.sharedInstance.baseUrl

let reportActiveDeviceURL            = baseUrlString + "active_devices.json"
let registerForPushNotificationsURL  = baseUrlString + "active_devices/dev_uuid.json"
let getAllPublicationsURL            = baseUrlString + "publications.json"
let postNewPublicationURL            = baseUrlString + "publications.json"
let reportArrivedToPublicationURL    = baseUrlString + "publications/"
let reportsForPublicationBaseURL     = baseUrlString + "publications/"
let reportUserLocationURL            = baseUrlString + "active_devices/dev_uuid.json"
let getPublicationWithIdentifierURL  = baseUrlString + "publications/"
let deletePublicationURL             = baseUrlString + "publications/"
let unRegisterUserFromPublicationURL = baseUrlString + "publications/"

public class FCMockServer: NSObject , FCServerProtocol {
    
    //fetches a publication with a certain identifier
    //called when a newPublication remote notification has arrived
    
    func fetchPublicationWithIdentifier(identifier: PublicationIdentifier ,completion: (publication: FCPublication) ->  Void) {
        
        let uniqueId = identifier.uniqueId
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getPublicationWithIdentifierURL + "\(uniqueId)")
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response  {
                let aServerResponse = serverResponse as! NSHTTPURLResponse
                print("response: \(serverResponse.description)", terminator: "")

                
                if error == nil && aServerResponse.statusCode == 200{
                   
                    if let data = data {
                    let publicationDict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                    
                    if let params = publicationDict {

                        let publication = FCPublication.publicationWithParams(params)

                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(publication: publication)
                        })
                        
                    }
                    }
                }
            }
        })
        task.resume()
    }
    
    ///
    /// reports device token to our server to use for APNS.
    /// old token can be nil (for the first report).
    /// we don't use the old token
    public func reportDeviceTokenForPushWithDeviceNewToken(newtoken:String) {
        
        var params = [String: AnyObject]()
        params["is_ios"] = true
        params["dev_uuid"] = FCModel.sharedInstance.deviceUUID
        params["remote_notification_token"] = newtoken
        
        let dictToSend = ["active_device" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dictToSend, options: [])
        //let devId = FCModel.sharedInstance.deviceUUID!
        let url = NSURL(string: registerForPushNotificationsURL)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData!
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let theResponse = response {
            
                let serverResponse = theResponse as! NSHTTPURLResponse
                print("respons: \(serverResponse.description)", terminator: "")
                print("status code: \(serverResponse.statusCode) ***************")
                
                if error != nil || serverResponse.statusCode != 200 {

                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidReportPushNotificationToServerKey)
                    FCUserNotificationHandler.sharedInstance.resendPushNotificationToken()
                }
                else {
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidReportPushNotificationToServerKey)
                }
            }
            
        })
        
        task.resume()
    }
    
    public func reportDeviceUUID(uuid: String) {
        
        let deviceId = uuid
        var remoteNotificationToken = NSUserDefaults.standardUserDefaults().objectForKey(kRemoteNotificationTokenKey) as? String
        if remoteNotificationToken == nil {remoteNotificationToken = "no"}
        let isIos = true
        let currentLatitude = FCModel.sharedInstance.userLocation.coordinate.latitude
        let curruntLongitude = FCModel.sharedInstance.userLocation.coordinate.longitude
        
        var params = [String:AnyObject]()
        params["dev_uuid"] = deviceId
        params["remote_notification_token"] = remoteNotificationToken
        params["is_ios"] = isIos
        params["last_location_latitude"] = currentLatitude
        params["last_location_longitude"] = curruntLongitude
        
        let dictToSend = ["active_device" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dictToSend, options: [])
        
        let url = NSURL(string: reportActiveDeviceURL)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let response = response {
            
                let serverResponse = response as! NSHTTPURLResponse
            
                if error != nil || serverResponse.statusCode != 200 {

                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidReportDeviceUUIDToServer)
                    FCModel.sharedInstance.reportDeviceUUIDToServer()
                }
                else {
                
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidReportDeviceUUIDToServer)

                }
            }
        })
        
        task.resume()
    }
    
    
    ///
    /// reports the user’s last known location. the server uses this information
    ///  to send push notification of a new Publication with defined radius.
    /// called at launch & before the app goes to background mode.
    ///
    
    public func reportUserLocation() {
        
        let location = FCModel.sharedInstance.userLocation.coordinate
        var params = [String: AnyObject]()
        params["last_location_longitude"] = location.longitude
        params["last_location_latitude"] = location.latitude
        params["dev_uuid"] = FCModel.sharedInstance.deviceUUID
        
        let dictToSend = ["active_device" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dictToSend, options: [])
        print(dictToSend)
        
        let url = NSURL(string: reportUserLocationURL)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData!
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let theResponse = response {
                
                let serverResponse = theResponse as! NSHTTPURLResponse
                
                if error != nil || serverResponse.statusCode == 200 {
                    print("success")
                }
            }
        })
        
        task.resume()
    }
    
    ///
    /// fetch all publications from server.
    ///
    public func downloadAllPublicationsWithCompletion(completion:(thePublications: [FCPublication]) -> Void){
        
        //Uncomment to use local mock data
        //let pubs = self.makePublication()
        //completion(thePublications: pubs)
        
       
        var publications = [FCPublication]()
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getAllPublicationsURL)
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if var serverResponse = response  {
                serverResponse = serverResponse as! NSHTTPURLResponse
            
            print("response: \(serverResponse.description)", terminator: "")
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                
                if let data = data {
                let arrayOfPublicationDicts = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String : AnyObject]]
                    
                    if let arrayOfPublicationDicts = arrayOfPublicationDicts {
                
                        for publicationDict in arrayOfPublicationDicts {
                   
                            let publication = FCPublication.publicationWithParams(publicationDict)
                            publications.append(publication)
                        }
                
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(thePublications: publications)
                        })
                    }
                }
            })
            }
        })
        task.resume()
    }
    
    ///
    /// fetch all reports to a certain Publication
    ///
    public func reportsForPublication(publication:FCPublication, completion:
        (success: Bool, reports: [FCOnSpotPublicationReport]?)->()) {
        
        let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId)" + "/publication_reports.json?publication_version=" + "\(publication.version)"
        
        //uncomment to check the mock report on server
        //var urlTempString = reportsForPublicationBaseURL + "3" + "/publication_reports.json?publication_version=1"
        
        var publicationReports = [FCOnSpotPublicationReport]()
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: urlString)
        
        let task = session.dataTaskWithURL(url!, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let theResponse = response {
                
               let serverResponse = theResponse as! NSHTTPURLResponse
                
                if error == nil && serverResponse.statusCode == 200 {
                    if let data = data {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        
                        
                        let arrayOfReports = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String : AnyObject]]
                        
                        if let arrayOfReports = arrayOfReports {
                        
                            for publicationReportDict in arrayOfReports {
                                print(publicationReportDict, separator: "=======", terminator: "=====REPORT=====")
                                let reportMessage = publicationReportDict["report"] as? Int ?? 1
                                let reportDateString = publicationReportDict["date_of_report"] as? NSString ?? ""
                                let reportDateDouble = reportDateString.doubleValue
                                //let timeInterval = NSTimeInterval(reportDateInt)
                                let reportDate = NSDate(timeIntervalSince1970: reportDateDouble)
                                let reportContactInfo = publicationReportDict["report_contact_info"] as? String ?? ""
                                let reportPublicationId = publicationReportDict["publication_id"] as? Int ?? 0
                                let reportPublicationVersion = publicationReportDict["publication_version"] as? Int ?? 0
                                let reportId = publicationReportDict["id"] as? Int ?? 0
                                let reportCollectorName = publicationReportDict["report_user_name"] as? String ?? ""
                                
                                
                                //prevent wrong data
                                if reportMessage != 1 && reportMessage != 3 && reportMessage != 5 {continue}
                                
                                let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage(rawValue: reportMessage)!, date: reportDate , reportContactInfo: reportContactInfo, reportPublicationId: reportPublicationId, reportPublicationVersion: reportPublicationVersion,reportId: reportId, reportCollectorName: reportCollectorName)
                                publicationReports.append(report)
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                completion(success: true, reports: publicationReports)
                            })
                        }
                    })
                }
                }
                else {
                    completion(success: false, reports: nil)
                }
            }
            
        })
        task.resume()
    }
    
    func registerUserForPublication(publication: FCPublication) {
        
        //we are currently only registering the user. we should think of how to delete a registration. should it be through a delete service or add the registration message to this payload.
        
        let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId)/registered_user_for_publications.json"
        
        var params = [String : AnyObject]()
        params["publication_id"] = publication.uniqueId
        params["publication_version"] = publication.version
        params["date_of_registration"] = Int(NSDate().timeIntervalSince1970)
        params["active_device_dev_uuid"] = FCModel.sharedInstance.deviceUUID
        params[kPublicationRegistrationContactInfoKey] = User.sharedInstance.userPhoneNumber ?? ""
        params[kPublicationRegistrationCollectorNameKey] = User.sharedInstance.userName
        let dicToSend = ["registered_user_for_publication" : params]
        print(dicToSend)
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
        print(dicToSend)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)")
//                let mydata = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
//                println("response data: \(mydata)")
                
                if error != nil || serverResponse.statusCode != 200 {
                    //we currently implement as best effort. nothing is done with an error
                }
            }
        })
        
        task.resume()
        
    }
    
    //unregister
    
    func unRegisterUserFromComingToPickUpPublication(publication: FCPublication, completion: (success: Bool) -> Void) {

        let uniqueId = publication.uniqueId
        let publicationVersion = publication.version
        let deviceUUID = FCModel.sharedInstance.deviceUUID
        
        var params = [String : AnyObject]()
        params["active_device_dev_uuid"] = deviceUUID
        params["publication_version"] = publicationVersion
        params["publication_id"] = uniqueId
        params["date_of_registration"] = 11243423
        
        let dicToSend = ["registered_user_for_publication" : params]
        print("params: \(dicToSend)")

        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dicToSend, options: [])

        let url = NSURL(string: unRegisterUserFromPublicationURL + "\(uniqueId)" + "/registered_user_for_publications/5")
        print("url: \(url)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
     
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)", terminator: "")
                if error != nil || serverResponse.statusCode != 200 {
                    //we currently implement as best effort. nothing is done with an error
                    print("Unregister for publication error: \(error)")
                }
            }
        })
        task.resume()
    }
    
    ///
    /// reports a Report of a Publication by a user that arrived at a publication
    ///  spot
    ///
    public func reportArrivedPublication(publication: FCPublication,withReport report:FCOnSpotPublicationReport) {
       
        let urlString = reportArrivedToPublicationURL + "\(publication.uniqueId)/publication_reports.json"

        var params = [String: AnyObject]()
        params["publication_id"]            = publication.uniqueId
        params["publication_version"]       = publication.version
        params["active_device_dev_uuid"]    = FCModel.sharedInstance.deviceUUID
        params["date_of_report"]            = report.date.timeIntervalSince1970
        params["report"]                    = report.onSpotPublicationReportMessage.rawValue
        params["report_contact_info"]       = report.reportContactInfo
        params["report_user_name"]          = report.reportCollectorName
        
        
        
        let dicToSend = ["publication_report" : params]
        print(dicToSend)
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dicToSend, options: [])
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print("params: \(params)")
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request,
            completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
             print("response: \(serverResponse)")
                if error != nil || serverResponse.statusCode != 200 {
                    //we currently implement as best effort. nothing is done with an error
                }
            }
        }).resume()
    }
    
    
    ///
    /// post a new Publication to the server
    ///
  
    public func postNewCreatedPublication(params:[String:AnyObject],
        completion:(success: Bool, uniqueID: Int, version: Int)->()) {
        
        var paramsToSend = params
        paramsToSend["active_device_dev_uuid"] = FCModel.sharedInstance.deviceUUID
        paramsToSend["is_on_air"] = true
        paramsToSend["photo_url"] = ""
        let pubDict = ["publication" : paramsToSend]
        print(pubDict)

        let jsonData = try? NSJSONSerialization.dataWithJSONObject(pubDict, options: [])
        let url = NSURL(string: postNewPublicationURL)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)")
                print("response error: \(serverResponse)")
                print("error: \(error)")
                
                
                if error == nil && serverResponse.statusCode == 200 {
                    
                    if let data = data {
                   
                    //we currently implement as best effort. nothing is done with an error
                    let dict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                        
                        if let dict = dict {

                            let uniqueId = dict[kPublicationUniqueIdKey] as! Int
                            let version = dict[kPublicationVersionKey] as! Int
                            completion(success: true, uniqueID: uniqueId, version: version)
                        }
                    }
                }
                else {
                    completion(success: false, uniqueID: 0, version: 0)
                }
            }
        })
        
        task.resume()
    }
    
    func postEditedPublication(params:[String:AnyObject],publication: FCPublication,
        completion:(success: Bool,  version: Int)->()) {
        
        var paramsToSend = params

        paramsToSend["active_device_dev_uuid"] = FCModel.sharedInstance.deviceUUID
        paramsToSend["is_on_air"] = true
        paramsToSend["photo_url"] = ""
        let pubDict = ["publication" : paramsToSend]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(pubDict, options: [])
        let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId).json"
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("post edited publication response: \(serverResponse)")
                if error == nil && serverResponse.statusCode == 200 {
                    if let data = data {
                    let dict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                        if let dict = dict {
                    
                            let version = dict[kPublicationVersionKey] as! Int
                            completion(success: true,  version: version)
                        }
                    }
                }
                else {
                    completion(success: false, version: 0)
                }
            }
        })
        
        task.resume()
    }
    
    func takePublicationOffAir(publication: FCPublication, completion: (success:Bool)->Void) {
        
        var params = [String:AnyObject]()
        params["is_on_air"] = false
        let pubDict = ["publication" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(pubDict, options: [])
        
        let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId).json"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let serverResponse = response as? NSHTTPURLResponse {
                print("respons: \(serverResponse.description)", terminator: "")
                
                
                if error == nil && serverResponse.statusCode == 200 {
                    
                    completion(success: true)
                }
                else {
                    completion(success: false)
                }
            }
        })
        
        task.resume()
    }
    
    func deletePublication(publicationIdentifier: PublicationIdentifier , completion: (success: Bool) -> ()) {

        let publicationUniqueID = publicationIdentifier.uniqueId
        
        let url = NSURL(string: deletePublicationURL + "\(publicationUniqueID)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        
        
//        var params = [String:AnyObject]()
//        params[kPublicationUniqueIdKey] = publicationIdentifier.uniqueId
//        params[kPublicationVersionKey] = publicationIdentifier.version
//        var pubDict = ["publication" : params]
//        
//        let jsonData = NSJSONSerialization.dataWithJSONObject(pubDict, options: nil, error: nil)
//        
//        request.HTTPBody = jsonData
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let response = response {
                let serverResponse = response as! NSHTTPURLResponse
                
                print("DELETE PUBLICATION RESPONSE: \(serverResponse)")
                
                if error != nil || serverResponse.statusCode != 200 {
                   
                    print("ERROR DELETING: \(error)")
                 //   completion(success: false)
                }
            }
            else {
              //  completion(success: false)
            }
        })
        
        
        task.resume()

    
    }
    
}

//public extension FCMockServer {
//    
//    public func makePublication () -> [FCPublication] {
//        
//        var publicaions = [FCPublication]()
//        var uniqueId = 111111
//        var title = "תפוחים ירוקים מהעץ"
//        var subtitle = "השארתי על הגדר מחוץ לבית"
//        var address = "רחוב שדרות בנימין 16, הוד השרון"
//        var typeOfCollecting = FCTypeOfCollecting.ContactPublisher
//        var coordinate = CLLocationCoordinate2D(latitude: 32.361233, longitude: 34.867452)
//        var startingDate = NSDate()
//        var endingDate = NSDate(timeIntervalSinceNow: 129600)
//        var contactInfo = "0544448246"
//        var photoUrl = "www.url.com"
//        var version = 2
//        
//        let pub1 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
//        pub1.countOfRegisteredUsers = 2
//        var report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage.HasMore, date: startingDate)
//        pub1.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
//        pub1.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
//        pub1.reportsForPublication.append(report)
//        
//        publicaions.append(pub1)
//        
//        uniqueId = 2222222
//        title = "50 קג עוף צלוי"
//        subtitle = "כנפי עוף שהופשרו אתמול. נא להזדרז!"
//        address = "מושב בית הלוי"
//        typeOfCollecting = FCTypeOfCollecting.FreePickUp
//        coordinate = CLLocationCoordinate2D(latitude: 32.357868, longitude: 34.934164)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: -360000)
//        photoUrl = "www.guy.com"
//        version = 1
//        
//        let pub2 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,contactInfo: contactInfo, subTitle: subtitle, version: version)
//        pub2.countOfRegisteredUsers = 4
//        
//        report.date = endingDate
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub2.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub2.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub2.reportsForPublication.append(report)
//        publicaions.append(pub2 )
//        
//        
//        uniqueId = 3333333
//        title = "35 מנות מוכנות"
//        subtitle = "מנות ראשונות ומנות עיקריות בקופסאות פלסטיק"
//        address = "רופין 19 תל אביב"
//        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
//        coordinate = CLLocationCoordinate2D(latitude: 32.381214, longitude: 34.882611)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: -345600)
//        contactInfo = "0544448246"
//        photoUrl = "www.denis.com"
//        version = 1
//        
//        let pub3 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
//        pub3.countOfRegisteredUsers = 6
//        report.date = endingDate
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub3.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub3.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
//        pub3.reportsForPublication.append(report)
//        
//        publicaions.append(pub3)
//        
//        uniqueId = 444444
//        title = "צלי בקר ממסיבת חתונה"
//        subtitle = "5 ק״ג אנטריקוט"
//        address = "טשרנחובסקי 5 רעננה"
//        typeOfCollecting = FCTypeOfCollecting.FreePickUp
//        coordinate = CLLocationCoordinate2D(latitude: 32.357622, longitude: 34.908564)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: 266000)
//        photoUrl = "www.denis.com"
//        version = 1
//        
//        let pub4 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
//        pub4.countOfRegisteredUsers = 4
//        report.date = endingDate
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub4.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub4.reportsForPublication.append(report)
//        publicaions.append(pub4)
//        
//        uniqueId = 555555
//        title = "55 מנות חומוס"
//        subtitle = "חומוס עוזי המקורי!"
//        address = "רחוב שער העמק 17 נתניה"
//        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
//        coordinate = CLLocationCoordinate2D(latitude: 32.350807, longitude: 34.908221)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: 266000)
//        photoUrl = "www.maayan.com"
//        version = 1
//        
//        let pub5 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: contactInfo, subTitle: subtitle, version: version)
//        pub4.countOfRegisteredUsers = 4
//        report.date = startingDate
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub5.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
//        pub5.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
//        pub5.reportsForPublication.append(report)
//        
//        publicaions.append(pub5)
//        
//        uniqueId = 666666
//        title = "סנדביץ׳ אבוקדו"
//        subtitle = "נשאר בקפיטריה של אוניברסיטת תל אביב"
//        address = "רחוב איינשטיין תל אביב"
//        typeOfCollecting = FCTypeOfCollecting.FreePickUp
//        coordinate = CLLocationCoordinate2D(latitude: 32.140298, longitude: 34.848289)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: -266000)
//        photoUrl = "www.denis.com"
//        version = 1
//        
//        let pub6 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
//        pub6.countOfRegisteredUsers = 6
//        report.date = startingDate
//        
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.NothingThere
//        report.date = endingDate
//        pub6.reportsForPublication.append(report)
//        
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
//        report.date = startingDate
//        pub6.reportsForPublication.append(report)
//        publicaions.append(pub6)
//        
//        uniqueId = 777777
//        title = "מרק חם"
//        subtitle = "75 מנות מרק עוף טרי"
//        address = "כיכר העצמאות נתניה"
//        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
//        coordinate = CLLocationCoordinate2D(latitude: 32.349792, longitude: 34.880111)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: 266000)
//        photoUrl = "www.denis.com"
//        version = 1
//        
//        let pub7 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: contactInfo, subTitle: subtitle, version: version)
//        pub7.countOfRegisteredUsers = 10
//        
//        report.date = startingDate
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub7.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub7.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
//        pub7.reportsForPublication.append(report)
//        publicaions.append(pub7)
//        
//        uniqueId = 888888
//        title = "10 מנות פלאפל"
//        subtitle = "פלאפל התחנה"
//        address = "מחלף נתניה"
//        typeOfCollecting = FCTypeOfCollecting.FreePickUp
//        coordinate = CLLocationCoordinate2D(latitude: 32.277409, longitude: 34.883995)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: 266000)
//        photoUrl = "www.denis.com"
//        
//        
//        let pub8 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address,  contactInfo: nil, subTitle: subtitle, version: version)
//        pub8.countOfRegisteredUsers = 3
//        report.date = startingDate
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub8.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.HasMore
//        pub8.reportsForPublication.append(report)
//        report.onSpotPublicationReportMessage = FCOnSpotPublicationReportMessage.TookAll
//        pub8.reportsForPublication.append(report)
//        publicaions.append(pub8)
//        
//        uniqueId = 999999
//        title = "חמוצים בייתיים"
//        subtitle = "ךימון כבוש, זייתים ירוקים"
//        address = "רחוב המעלות 2 כפר יונה"
//        typeOfCollecting = FCTypeOfCollecting.ContactPublisher
//        coordinate = CLLocationCoordinate2D(latitude: 32.296855, longitude: 34.914207)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: 266000)
//        photoUrl = "www.denis.com"
//        
//        let pub9 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: contactInfo, subTitle: subtitle, version: version)
//        pub9.countOfRegisteredUsers = 0
//        publicaions.append(pub9)
//        
//        uniqueId = 101010
//        title = "מוקפץ תאילנדי"
//        subtitle = "2 ק״ג מוקפץ חם וטרי"
//        address = "קניון השרון נתניה, קומה א׳"
//        typeOfCollecting = FCTypeOfCollecting.FreePickUp
//        coordinate = CLLocationCoordinate2D(latitude: 32.318038, longitude: 34.857559)
//        startingDate = NSDate()
//        endingDate = NSDate(timeIntervalSinceNow: 266000)
//        photoUrl = "www.denis.com"
//        
//        let pub10 = FCPublication(coordinates: coordinate, theTitle: title, endingDate: endingDate, typeOfCollecting: typeOfCollecting, startingDate: startingDate, uniqueId: uniqueId, address: address, contactInfo: nil, subTitle: subtitle, version: version)
//        pub10.countOfRegisteredUsers = 1
//        publicaions.append(pub10)
//        
//        return publicaions
//    }
//}
