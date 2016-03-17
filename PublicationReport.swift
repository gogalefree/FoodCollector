//
//  PublicationReport.swift
//  FoodCollector
//
//  Created by Guy Freedman on 27/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import CoreData


class PublicationReport: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    
    class func reportsFromWebFetchForPublication(publication: Publication, arrayOfDicts: [[String : AnyObject]], context: NSManagedObjectContext) {
        
        
        for publicationReportDict in arrayOfDicts {
            
            print(publicationReportDict, separator: "=======", terminator: "=====REPORT=====")
            print("\n")
            
            let reportContactInfo = publicationReportDict["report_contact_info"] as? String ?? ""
            let reporterActiveDeviceUUID = publicationReportDict["active_device_dev_uuid"] as? String ?? ""
            let reportDateString = publicationReportDict["date_of_report"] as? NSString ?? ""
//            let reportPublicationVersion = publicationReportDict["publication_version"] as? Int ?? 0
//            let reportPublicationId = publicationReportDict["publication_id"] as? Int ?? 0
            let reporterUserId = publicationReportDict["reporter_user_id"] as? Int ?? 0
            let reportId = publicationReportDict["id"] as? Int ?? 0
            let reportMessage = publicationReportDict["report"] as? Int ?? 1
            let reportCollectorName = publicationReportDict["report_user_name"] as? String ?? ""
            
            let reportDateDouble = reportDateString.doubleValue
            let reportDate = NSDate(timeIntervalSince1970: reportDateDouble)
            
            //prevent wrong data
            if reportMessage != 1 && reportMessage != 3 && reportMessage != 5 {continue}
            
            let request = NSFetchRequest(entityName: kPublicationReportEntity)
            let predicate = NSPredicate(format: "id = %@", NSNumber(integer: reportId) )
            request.predicate = predicate
            
            
                let results = try! context.executeFetchRequest(request) as? [PublicationReport]
                guard let existing = results else { return }
                if existing.count == 0 {
                    
                    let report = NSEntityDescription.insertNewObjectForEntityForName(kPublicationReportEntity, inManagedObjectContext: context) as? PublicationReport
                    guard let newReport = report else {return}
                    
                    newReport.reporterContactInfo = reportContactInfo
                    newReport.activeDeviceDecUUID = reporterActiveDeviceUUID
                    newReport.dateOfReport = reportDate
                    newReport.id = reportId
                    newReport.publicationId = publication.uniqueId
                    newReport.publicationVersion = publication.version
                    newReport.reoprterUserName = reportCollectorName
                    newReport.report = reportMessage
                    newReport.reporterUserId = reporterUserId
                    newReport.publication = publication
                    
                    if publication.reports == nil {publication.reports = NSSet()}
                    publication.reports = publication.reports?.setByAddingObject(newReport)
                    
                    if publication.didRegisterForCurrentPublication?.boolValue == true {
                        
                        publication.didRecieveNewReport = true
                        let newReportLog = ActivityLog.LogType.Report.rawValue
                        ActivityLog.activityLog(publication, group: nil, type: newReportLog, context: context)
                        
                        //TODO: check if the report contains "took all" and the current user is the publisher
                        
                        //FCUserNotificationHandler.sharedInstance.incrementNotificationsBadgeNumberIfNeededForType(kRemoteNotificationTypePublicationReport, publication: publication)
                    }
                    
                }
        }
    }
    
    class func reportForPublication(reportInt: Int ,publication: Publication, context: NSManagedObjectContext)  -> PublicationReport {
        let report = NSEntityDescription.insertNewObjectForEntityForName(kPublicationReportEntity, inManagedObjectContext: context) as! PublicationReport
        report.reporterContactInfo = User.sharedInstance.userPhoneNumber
        report.activeDeviceDecUUID = FCModel.sharedInstance.deviceUUID
        report.dateOfReport = NSDate()
        report.publicationId = publication.uniqueId
        report.publicationVersion = publication.version
        report.reoprterUserName = User.sharedInstance.userIdentityProviderUserName
        report.report = NSNumber(integer: reportInt)
        report.reporterUserId = NSNumber(integer: User.sharedInstance.userUniqueID)
        report.publication = publication
        
        if publication.reports == nil {publication.reports = Set<PublicationReport>()}
        publication.reports = publication.reports?.setByAddingObject(report)
        
        do {
            try context.save()
        }catch {
            print("error saving new report \(error) " + __FUNCTION__)
        }
        
        return report        
    }
    
    func toString() {
        
        print("reporter name \(reoprterUserName) contact: \(reporterContactInfo) publicationID: \(publicationId) ")
    }
}
