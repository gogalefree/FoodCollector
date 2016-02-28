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
                        
                        //added
                        //Publication.publicationsFromWebFetch(arrayOfPublicationDicts)
                        CDNewDataProcessor.processDataFromWebFetch(arrayOfPublicationDicts)
                
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
    //*******************************
    //DEPRECATED v1.0.9
    //use FDServer+PublicationReports
    //*******************************
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
                                print("\n")
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
    
    //*************************************
    //DEPRECATED v1.0.9
    //use CDPublicationRegistrationsFetcher
    //*************************************
    func registerUserForPublication(publication: FCPublication) {
        
        //we are currently only registering the user. we should think of how to delete a registration. should it be through a delete service or add the registration message to this payload.
        
        let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId)/registered_user_for_publications.json"
        let registration = publication.registrationsForPublication.last!
        var params = [String : AnyObject]()
        params["publication_id"] = publication.uniqueId
        params["publication_version"] = publication.version
        params["date_of_registration"] = registration.dateOfOrder.timeIntervalSince1970
        params["active_device_dev_uuid"] = FCModel.sharedInstance.deviceUUID
        params[kPublicationRegistrationContactInfoKey] = registration.contactInfo ?? ""
        params[kPublicationRegistrationCollectorNameKey] = registration.collectorName
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
        let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}-").invertedSet
        let deviceUUID = FCModel.sharedInstance.deviceUUID?.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
        print("device uuid escaped: \(deviceUUID)")
        let uuid = deviceUUID ?? ""
        print("uuid escaped: \(uuid)")

        var params = [String : AnyObject]()
        params["active_device_dev_uuid"] = deviceUUID
        params["publication_version"] = publicationVersion
        params["publication_id"] = uniqueId
        params["date_of_registration"] = 11243423
        params["collector_contact_info"] = User.sharedInstance.userPhoneNumber ?? ""
        params["collector_name"] = User.sharedInstance.userIdentityProviderUserName ?? ""
        
        let dicToSend = ["registered_user_for_publication" : params]
        print("params: \(dicToSend)")

        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dicToSend, options: [])

        let url = NSURL(string: unRegisterUserFromPublicationURL + "\(uniqueId)" + "/registered_user_for_publications/1?publication_version=\(publicationVersion)&active_device_dev_uuid=\(uuid)")
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
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            if let response = response {
                let serverResponse = response as! NSHTTPURLResponse
                
                print("DELETE PUBLICATION RESPONSE: \(serverResponse)")
                
                if error != nil || serverResponse.statusCode != 200 {
                   
                    print("ERROR DELETING: \(error)")
                    completion(success: false)
                }
            }
            else {
                completion(success: false)
            }
        })
        
        
        task.resume()

    
    }
    
}
