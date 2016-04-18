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
    //called when a newPublication remote notification has arrived while the app is active
    
    func fetchPublicationWithIdentifier(identifier: PublicationIdentifier ,completion: (publication: Publication?) ->  Void) {
        
        let uniqueId = identifier.uniqueId
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: getPublicationWithIdentifierURL + "\(uniqueId)")
        let task = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let serverResponse = response  {
                let aServerResponse = serverResponse as! NSHTTPURLResponse
                print("response: \(serverResponse.description)", terminator: "")

                
                if error == nil && aServerResponse.statusCode < 300{
                   
                    if let data = data {
                    
                        let publicationDict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                    
                        if let params = publicationDict {


                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                              
                                let moc = FCModel.dataController.managedObjectContext
                                moc.performBlock({ () -> Void in
                                    
                                    
                                    if let existingPublication = FCModel.sharedInstance.publicationWithUniqueId(identifier) {
                                        
                                        existingPublication.updateFromParams(params, context: moc)
                                        FCUserNotificationHandler.sharedInstance.makeActivityLogForType(ActivityLog.LogType.EditedPublication , publication: existingPublication)
                                        completion(publication: existingPublication)
                                    }
                                    
                                    else {
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            
                                            moc.performBlock({ () -> Void in
                                                let publication = NSEntityDescription.insertNewObjectForEntityForName(kPublicationEntity, inManagedObjectContext: moc) as! Publication
                                                publication.updateFromParams(params, context: moc)
                                                ActivityLog.activityLog(publication, group: nil,  type: ActivityLog.LogType.NewPublication.rawValue, context: moc)
                                                FCModel.sharedInstance.publications.append(publication)
                                                completion(publication: publication)

                                            })
                                        })
                                    }
                                })
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
                    //FCUserNotificationHandler.sharedInstance.resendPushNotificationToken()
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
        
        //set the location in user defaults
        NSUserDefaults.standardUserDefaults().setDouble(location.latitude, forKey: kUserLastLatitudeKey)
        NSUserDefaults.standardUserDefaults().setDouble(location.longitude, forKey: kUserLastLongitudeKey)

        
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
    func downloadAllPublications(){
        
       
       // var publications = [FCPublication]()
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
                        
                    
                        //added v1.0.9
                        CDNewDataProcessor.processDataFromWebFetch(arrayOfPublicationDicts)
                    }
                }
            })
            }
        })
        task.resume()
    }
    
    
      
//    ///
//    /// reports a Report of a Publication by a user that arrived at a publication
//    ///  spot
//    ///DEPRECATED v1.0.9
//    public func reportArrivedPublication(publication: FCPublication,withReport report:FCOnSpotPublicationReport) {
//       
//        let urlString = reportArrivedToPublicationURL + "\(publication.uniqueId)/publication_reports.json"
//
//        var params = [String: AnyObject]()
//        params["publication_id"]            = publication.uniqueId
//        params["publication_version"]       = publication.version
//        params["active_device_dev_uuid"]    = FCModel.sharedInstance.deviceUUID
//        params["date_of_report"]            = report.date.timeIntervalSince1970
//        params["report"]                    = report.onSpotPublicationReportMessage.rawValue
//        params["report_contact_info"]       = report.reportContactInfo
//        params["report_user_name"]          = report.reportCollectorName
//        
//        
//        
//        let dicToSend = ["publication_report" : params]
//        print(dicToSend)
//        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dicToSend, options: [])
//        let url = NSURL(string: urlString)
//        let request = NSMutableURLRequest(URL: url!)
//        request.HTTPMethod = "POST"
//        request.HTTPBody = jsonData
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        print("params: \(params)")
//        let session = NSURLSession.sharedSession()
//        session.dataTaskWithRequest(request,
//            completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
//            
//            if let serverResponse = response as? NSHTTPURLResponse {
//             print("response: \(serverResponse)")
//                if error != nil || serverResponse.statusCode != 200 {
//                    //we currently implement as best effort. nothing is done with an error
//                }
//            }
//        }).resume()
//    }
//    
    
    ///
    /// post a new Publication to the server
    ///
  
    public func postNewCreatedPublication(params:[String:AnyObject],
        completion:(success: Bool, params: [String: AnyObject])->()) {
        
            var paramsToSend = params
            paramsToSend[kPublicationActiveDeviceUUIDKey] = FCModel.sharedInstance.deviceUUID
            paramsToSend[kPublicationIsOnAirKey] = true
            paramsToSend[kPublicationPhotoUrl] = ""
            paramsToSend[kPublicationPublisherIdKey] = User.sharedInstance.userUniqueID
            paramsToSend[kPublicationContactInfoKey] = User.sharedInstance.userPhoneNumber
            paramsToSend[kPublicationPublisherUserNameKey] = User.sharedInstance.userIdentityProviderUserName
            paramsToSend[kPublicationTypeOfCollectingKey] = 2
            
            
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
                
                
                if error == nil && serverResponse.statusCode < 300 {
                    
                    if let data = data {
                   
                    //we currently implement as best effort. nothing is done with an error
                    let dict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                        
                        if let dict = dict {

                            completion(success: true, params: dict)
                        }
                    }
                }
                else {
                    completion(success: false, params: ["error" : "couldNotParsePublicationObject"])
                }
            }
        })
        
        task.resume()
    }
    
    func postEditedPublication(params:[String:AnyObject],publication: Publication,
        completion:(success: Bool,  version: Int)->()) {
        
            var paramsToSend = params
            paramsToSend[kPublicationActiveDeviceUUIDKey] = FCModel.sharedInstance.deviceUUID
            paramsToSend[kPublicationIsOnAirKey] = true
            paramsToSend[kPublicationPhotoUrl] = ""
            paramsToSend[kPublicationPublisherIdKey] = User.sharedInstance.userUniqueID
            paramsToSend[kPublicationContactInfoKey] = User.sharedInstance.userPhoneNumber
            paramsToSend[kPublicationPublisherUserNameKey] = User.sharedInstance.userIdentityProviderUserName
            paramsToSend[kPublicationTypeOfCollectingKey] = 2
        
            let pubDict = ["publication" : paramsToSend]
            let jsonData = try? NSJSONSerialization.dataWithJSONObject(pubDict, options: [])
            let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId!.integerValue).json"
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
                    if error == nil && serverResponse.statusCode < 300 {
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
    
    func takePublicationOffAir(publication: Publication, completion: (success:Bool)->Void) {
        
        let publicationID = publication.uniqueId!.integerValue
        var params = [String:AnyObject]()
        params[kPublicationIsOnAirKey] = false
        let pubDict = ["publication" : params]
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(pubDict, options: [])
        
        let urlString = reportsForPublicationBaseURL + "\(publicationID).json"
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
                    
                    if let data = data {
                        let dict = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String : AnyObject]
                        if let dict = dict {
                            
                            let version = dict[kPublicationVersionKey] as! Int
                            publication.version = NSNumber(integer: version)
                            do {
                                try publication.managedObjectContext?.save()
                            } catch {
                                print ("error saving publication after take off air: \(error)")
                            }
                        }
                    }

                    
                    
                    completion(success: true)
                }
                else {
                    completion(success: false)
                }
            }
        })
        
        task.resume()
    }
    
        
}
