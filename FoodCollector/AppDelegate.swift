//
//  AppDelegate.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/5/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import CoreLocation
import QuartzCore

let kRemoteNotificationTokenKey = "kRemoteNotificationTokenKey"
let kDidReportPushNotificationToServerKey = "didFailToRegisterPush"
let kDidReciveLocationNotificationInBackground = "didReciveNewLocationNotificationInBackground"

let kNavBarBlueColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let model = FCModel.sharedInstance
        model.foodCollectorWebServer = FCMockServer()
        model.setUp()
        
        let userNotificationHandler = FCUserNotificationHandler.sharedInstance
        userNotificationHandler.setup()

        setupUI()
        registerAWSS3()
        registreGoogleAnalytics()
        initGoogleSignin()
        setupFacebook(application, launchOptions: launchOptions)
       // User.sharedInstance.setValueInUserClassProperty(false, forKey: .IsLoggedIn)
        return true
    }
    
    func registerAWSS3() {

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityId: nil, accountId:  "458352772906", identityPoolId: "us-east-1:ec4b269f-88a9-471d-b548-7886e1f9f2d7", unauthRoleArn: "arn:aws:iam::458352772906:role/Cognito_food_collector_poolUnauth_DefaultRole", authRoleArn:  "arn:aws:iam::458352772906:role/Cognito_food_collector_poolAuth_DefaultRole", logins: nil)
    
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
       
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
       
        var token = deviceToken.description as NSString
        token = token.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        FCUserNotificationHandler.sharedInstance.registerForPushNotificationWithToken(token as String)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        //show UIAlert informing users to enable push from settings
        //the alert is presented in collector root vc
        print("FAILED TO REGISTER PUSH NOTIFICATIONS: \(error.description)")
        FCUserNotificationHandler.sharedInstance.registerForPushNotificationWithToken("no")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kShouldShowFailedToRegisterForPushAlertKey)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //called when a remote push arrives while in backround and the user tapped a button
        //if the action uses forground - the app is invoked
        //if the action uses backRound - the app calls this method in the backround

        UIApplication.sharedApplication().applicationIconBadgeNumber = 0

        
        if let id = identifier {
            
            if id == kUserNotificationShowActionId {
                //Show ui for new notification

                if userInfo[kRemoteNotificationType] as? String  != nil {
                    
                    FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(userInfo)
                }
            }
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let id = identifier {
            if id == kUserNotificationShowActionId {
                FCUserNotificationHandler.sharedInstance.didRecieveLocalNotification(notification)
            }
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        

        //called when the app recieves push while in foreground or backround
        //use UIApplication.sharedApplication().applicationState
        //to find out whether the app was susspended or not
        
        //if the app is in background Mode and we recived a delete notification
        //we delete it from the publications array
        
        
        if UIApplication.sharedApplication().applicationState != .Active {
           
            FCUserNotificationHandler.sharedInstance.handleNotificationFromBacground(userInfo)
            
        }
        
        else {
            
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(userInfo)
        }
        
        completionHandler(UIBackgroundFetchResult.NewData)

    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        FCUserNotificationHandler.sharedInstance.didRecieveLocalNotification(notification)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        //TODO: Add urk scheme for EU
        print("url: \(url.scheme)" + " " + __FUNCTION__)
        
        if url.scheme == "fb694275220709803" {
        
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        else if url.scheme == "com.googleusercontent.apps.863661704420-3i8i6342n0rped1ttm9c3ukvc6rald1g" {
            
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
            

        }
        else if url.scheme == "com.gogalefree.foodoneteu" {
            
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
            
            
        }
//        if #available(iOS 9.0, *) {
//            let options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!,
//                UIApplicationOpenURLOptionsAnnotationKey: annotation]
//       
//            
//        return self.application(application,
//            openURL: url,
//            options: options)
//        }
//       
        return true
    }
    
//    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
//        
//            print("url: \(url.scheme)" + " " + __FUNCTION__)
//
//            if #available(iOS 9.0, *) {
//                return GIDSignIn.sharedInstance().handleURL(url,
//                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
//                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
//            } else {
//                // Fallback on earlier versions
//            }
//        
//        
//        return false
//    }
//
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FCModel.sharedInstance.foodCollectorWebServer.reportUserLocation()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        FBSDKAppEvents.activateApp()

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        //TODO: delete before release
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        GIDSignIn.sharedInstance().signOut()

        
        //delete all photos
        let fm = NSFileManager.defaultManager()
        let photoPath = FCModel.sharedInstance.photosDirectoryUrl.path!
        let files = (try! fm.contentsOfDirectoryAtPath(photoPath)) 
        var error: NSError?
        for file in files {
            
            do {
                try fm.removeItemAtPath(photoPath.stringByAppendingString("/\(file)"))
            } catch let error1 as NSError {
                error = error1
                print("Error deleting file: \(error)")
            }
        }
    }
}

