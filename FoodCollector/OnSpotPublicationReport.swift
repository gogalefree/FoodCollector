//
//  OnSpotPublicationReport.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/11/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit
import Foundation

public struct FCOnSpotPublicationReport {
    
    let onSpotPublicationReportMessage  :FCOnSpotPublicationReportMessage
    let date                            :NSDate
    let reportContactInfo               :String
    let reportPublicationId             :Int
    let reportPublicationVersion        :Int
    var reportId                        :Int
    let reportCollectorName             :String
    
    
}

enum FCOnSpotPublicationReportMessage: Int {
    
    case NothingThere = 5
    case TookAll = 3
    case HasMore = 1
    
}


class OnSpotPublicationReport: NSObject {

    
    class func reportWithParams(params: [String: AnyObject]) -> FCOnSpotPublicationReport? {
    
    let reportMessage = params["report"] as? Int ?? 1
    let reportDateString = params["date_of_report"] as? NSString ?? ""
    let reportDateDouble = reportDateString.doubleValue
    //let timeInterval = NSTimeInterval(reportDateInt)
    let reportDate = NSDate(timeIntervalSince1970: reportDateDouble)
    let reportContactInfo = params["report_contact_info"] as? String ?? ""
    let reportPublicationId = params["publication_id"] as? Int ?? 0
    let reportPublicationVersion = params["publication_version"] as? Int ?? 0
    let reportId = params["id"] as? Int ?? 0
    let reportCollectorName = params["report_user_name"] as? String ?? ""
    
    
    //prevent wrong data
    if reportMessage != 1 && reportMessage != 3 && reportMessage != 5 {return nil}
    
    let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: FCOnSpotPublicationReportMessage(rawValue: reportMessage)!, date: reportDate , reportContactInfo: reportContactInfo, reportPublicationId: reportPublicationId, reportPublicationVersion: reportPublicationVersion,reportId: reportId, reportCollectorName: reportCollectorName)

        return report
    }

}
