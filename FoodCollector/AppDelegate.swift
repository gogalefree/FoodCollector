//
//  AppDelegate.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/5/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import CoreLocation

let kRemoteNotificationTokenKey = "kRemoteNotificationTokenKey"
let kDidFailToRegisterPushNotificationKey = "didFailToRegisterPush"
let kDidReciveLocationNotificationInBackground = "didReciveNewLocationNotificationInBackground"



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("fe")
        
        

        
        //uncomment to check the device uuid report service
        //NSUserDefaults.standardUserDefaults().removeObjectForKey(kDeviceUUIDKey)

        //uncomment to check the device push notification token report service
        //NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidFailToRegisterPushNotificationKey)
        
        
        let model = FCModel.sharedInstance
        model.foodCollectorWebServer = FCMockServer()
        model.setUp()
        
        let userNotificationHandler = FCUserNotificationHandler.sharedInstance
        userNotificationHandler.setup()
        
        if let option = launchOptions{
            
            if option[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
                let dict = option[UIApplicationLaunchOptionsRemoteNotificationKey] as! [String : AnyObject]
                FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(dict)
            }
            

            if option[UIApplicationLaunchOptionsLocalNotificationKey] != nil {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey:kDidReciveLocationNotificationInBackground)
                let not = option[UIApplicationLaunchOptionsLocalNotificationKey] as! UILocalNotification
                FCUserNotificationHandler.sharedInstance.didRecieveLocalNotification(not)
            }
        }
        registerAWSS3()
        return true
    }
    
    func registerAWSS3() {

       let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityId: nil, accountId:  "458352772906", identityPoolId: "us-east-1:ec4b269f-88a9-471d-b548-7886e1f9f2d7", unauthRoleArn: "arn:aws:iam::458352772906:role/Cognito_food_collector_poolUnauth_DefaultRole", authRoleArn:  "arn:aws:iam::458352772906:role/Cognito_food_collector_poolAuth_DefaultRole", logins: nil)
    
        
        /*
        let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            AWSRegionType.USEast1,
            accountId: "458352772906",
            identityPoolId: "us-east-1:ec4b269f-88a9-471d-b548-7886e1f9f2d7",
            unauthRoleArn: "arn:aws:iam::458352772906:role/Cognito_food_collector_poolUnauth_DefaultRole",
            authRoleArn: "arn:aws:iam::458352772906:role/Cognito_food_collector_poolAuth_DefaultRole"
        )
        */
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        //AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)
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
        println("FAILED TO REGISTER PUSH NOTIFICATIONS: \(error.description)")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidFailToRegisterPushNotificationKey)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //called when a remote push arrives while in backround and the user tapped a button
        //if the action uses forground - the app is invoked
        //if the action uses backRound - the app calls this method in the backround
        
        
        if let id = identifier {
            if id == kUserNotificationShowActionId {
                //Show ui for new notification
                FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(userInfo)
            
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
            if let notificationType = userInfo[kRemoteNotificationType] as? String {
                if notificationType == kRemoteNotificationTypeDeletedPublication {
                    self.deletePublication(userInfo)
                }
            }
        }
        else {
            FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.NewData)
        }
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        FCUserNotificationHandler.sharedInstance.didRecieveLocalNotification(notification)
    }


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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //delete all photos
        let fm = NSFileManager.defaultManager()
        var photoPath = FCModel.sharedInstance.photosDirectoryUrl.path!
        let files = fm.contentsOfDirectoryAtPath(photoPath, error: nil) as! [String]
        var error: NSError?
        for file in files {
            
            if !fm.removeItemAtPath(photoPath.stringByAppendingPathComponent("/\(file)"), error: &error) {
                println("Error deleting file: \(error)")
            }
        }
    }
    
    func deletePublication(userInfo: [NSObject: AnyObject]) {
        
        let data = userInfo[kRemoteNotificationDataKey]! as! [String : AnyObject]
        let uniqueId = data[kPublicationUniqueIdKey]! as! Int
        let version = data[kPublicationVersionKey]! as! Int

        let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent("publications")
        if NSFileManager.defaultManager().fileExistsAtPath(publicationsFilePath){
            var publications = NSKeyedUnarchiver.unarchiveObjectWithFile(publicationsFilePath) as! [FCPublication]
            for (index, publication) in enumerate(publications) {
                
                if version == publication.version && uniqueId == publication.uniqueId {
                    publications.removeAtIndex(index)
                    break
                }
            }
            
            NSKeyedArchiver.archiveRootObject(publications, toFile:publicationsFilePath)
        }
    }
}

