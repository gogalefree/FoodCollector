//
//  FDServer+PublicationReports.swift
//  FoodCollector
//
//  Created by Guy Freedman on 27/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData

extension FCMockServer {
    
    func reportsForPublication(publication:Publication,
        context: NSManagedObjectContext,
        completion: (success: Bool) -> Void ){
            
            let urlString = reportsForPublicationBaseURL + "\(publication.uniqueId!.integerValue)" + "/publication_reports.json?publication_version=" + "\(publication.version!.integerValue)"
        
            let session = NSURLSession.sharedSession()
            let url = NSURL(string: urlString)
            let task = session.dataTaskWithURL(url!, completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let theResponse = response {
                    
                    let serverResponse = theResponse as! NSHTTPURLResponse
                    
                    if error == nil && serverResponse.statusCode == 200 {
                        if let data = data {

                            
                                
                                let arrayOfReports = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String : AnyObject]]
                                
                                if let arrayOfReports = arrayOfReports {
                                    
                                    PublicationReport.reportsFromWebFetchForPublication(publication, arrayOfDicts: arrayOfReports, context: context)
                                    completion(success: true)
                                    
                                }
                            
                        }
                    }
                    else {
                        completion(success: false)
                    }
                }
                
            })
            task.resume()
    }

    func postReportforPublication(report: PublicationReport) {
        
        let publicationId = report.publicationId!.integerValue
        let urlString = reportArrivedToPublicationURL + "\(publicationId)/publication_reports.json"
        
        var params = [String: AnyObject]()
        params["publication_id"]            = publicationId
        params["publication_version"]       = report.publicationVersion!.integerValue
        params["active_device_dev_uuid"]    = FCModel.sharedInstance.deviceUUID
        params["date_of_report"]            = report.dateOfReport!.timeIntervalSince1970
        params["report"]                    = report.report!.integerValue
        params["report_contact_info"]       = report.reporterContactInfo ?? ""
        params["report_user_name"]          = report.reoprterUserName ?? ""
        params["reporter_user_id"]          = report.reporterUserId!.integerValue
        params["rating"]                    = report.publisherRating?.doubleValue
        
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
                    if error != nil || serverResponse.statusCode > 300 {
                        
                        print("error posting report \(error)")
                    }
                    
                    else {
                        guard let data = data else {return}
                        
                        do {
                            let reportDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String : AnyObject]
                            let id = reportDict?["id"] as? Int ?? 0
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                report.id = NSNumber(integer: id)
                                FCModel.sharedInstance.dataController.save()
                            })
                            
                        } catch {
                            print("error parsing report data \(error) ")
                        }
                    }
                }
        }).resume()
    }

}