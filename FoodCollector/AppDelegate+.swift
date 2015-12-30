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
      //  gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
        
//        GINInvite.applicationDidFinishLaunching()
//        
//        if (kTrackingID != "YOUR_TRACKING_ID") {
//            GINInvite.setGoogleAnalyticsTrackingId(kTrackingID)
//        }
//
    }
    
    func initGoogleSignin() {
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true

    }

    func setupFacebook(application: UIApplication,launchOptions: [NSObject: AnyObject]?) {
    
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        if (launchOptions?[UIApplicationLaunchOptionsURLKey] == nil) {
            
            FBSDKAppLinkUtility.fetchDeferredAppLink { (url, error) -> Void in
                
                if (error != nil) {
                    print("Received error while fetching deferred app link \(error)")
                }
                if (url != nil) {
                    
                    if UIApplication.sharedApplication().canOpenURL(url) {UIApplication.sharedApplication().openURL(url)}
                }
            }
        }
    }
    
    func setupUI() {
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        // Nav bar color hex string: #3197d3
        UINavigationBar.appearance().barTintColor = kNavBarBlueColor
        UINavigationBar.appearance().translucent = true
    }
    
}