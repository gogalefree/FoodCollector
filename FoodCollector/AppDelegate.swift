//
//  AppDelegate.swift
//  FoodCollector
//
//  Created by Guy Freedman on 11/5/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

let kRemoteNotificationTokenKey = "kRemoteNotificationTokenKey"
let kDidFailToRegisterPushNotificationKey = "didFailToRegisterPush"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let model = FCModel.sharedInstance
        model.foodCollectorWebServer = FCMockServer()
        model.setUp()
        
        let userNotificationHandler = FCUserNotificationHandler.sharedInstance
        userNotificationHandler.setup()
        
        if let option = launchOptions{
            
            if option[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
                let dict = option[UIApplicationLaunchOptionsRemoteNotificationKey] as [String : AnyObject]
                FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(dict)
            }
            
            if option[UIApplicationLaunchOptionsLocalNotificationKey] != nil {
                let not = option[UIApplicationLaunchOptionsLocalNotificationKey] as UILocalNotification
                FCUserNotificationHandler.sharedInstance.didRecieveLocalNotification(not)
            }
        }
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
       
        var token = deviceToken.description as NSString
        token = token.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        FCUserNotificationHandler.sharedInstance.registerForPushNotificationWithToken(token)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDidFailToRegisterPushNotificationKey)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        //show UIAlert informing users to enable push from settings
        //the alert is presented in collector root vc
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDidFailToRegisterPushNotificationKey)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        //called when a remote push arrives while in backround and the user tapped a button
        //if the action uses forground - the app is invoked
        //if the action uses backRound - the app calls this method in the backround
        
        FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(userInfo)
        
        if let id = identifier {
            if id == kUserNotificationShowActionId {
                //Show ui for new notification
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
        FCUserNotificationHandler.sharedInstance.didRecieveRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
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
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

