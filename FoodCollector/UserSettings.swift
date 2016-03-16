//
//  UserSettings.swift
//  FoodCollector
//
//  Created by Guy Freedman on 15/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class UserSettings: NSObject {
    
    private let kShouldPresentNotificationsKey  = "kShouldPresentNotificationsKey"
    private let kNotificationsRadiusKey         = "kNotificationsRadiusKey"
    
    
    var shouldPresentNotifications = true { //set by the settings vc screen
        didSet {
            if shouldPresentNotifications != oldValue { save() }
        }
    }
    
    
    var notificationsRadius = 100  {        //this is the default value meaning present all notifications
        didSet {
            if notificationsRadius != oldValue { save() }
        }
    }
    
    
    override init() {
        super.init()
        if NSUserDefaults.standardUserDefaults().objectForKey(kShouldPresentNotificationsKey) != nil {
         
            shouldPresentNotifications = NSUserDefaults.standardUserDefaults().boolForKey(kShouldPresentNotificationsKey) ?? true
            notificationsRadius        = NSUserDefaults.standardUserDefaults().integerForKey(kNotificationsRadiusKey) ?? 100
        }
    }
    
    func save() {
        
        NSUserDefaults.standardUserDefaults().setBool(shouldPresentNotifications, forKey: kShouldPresentNotificationsKey)
        NSUserDefaults.standardUserDefaults().setInteger(notificationsRadius, forKey: kNotificationsRadiusKey)
    }
    

}
