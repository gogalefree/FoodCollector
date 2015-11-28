//
//  GAController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 20/11/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

let kFAMainLanchScreenCategory = "Main Launch Screen"
let kFAThumbNailsCategory = "Collector Map thumbnails Action"

let kFAActivityCenterScreenName = "Activity Center Screen"
let kFAPublicationsTVCScreenName = "Publications Table View Screen"
let kFAPublicationDetailsScreenName = "Publication Details Screen"
let kFAPublisherRootVCScreenName = "Publisher Root VC"
let kFAPublicationEditorTVCScreenName = "Publication Editor TVC"
let kFAPublicationReportScreenName = "Publication Report Screen"






class GAController {
    
    class func sendAnalitics(category: String, action: String, label: String, value: Int) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build() as [NSObject : AnyObject])
    }
    
    class func reportsAnalyticsForScreen(screenName: String){
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}