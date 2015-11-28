//
//  AppDelegate+.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func registreGoogleAnalytics() {

        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
    }

    
}