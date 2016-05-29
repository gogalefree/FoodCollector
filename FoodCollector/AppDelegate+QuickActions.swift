//
//  AppDelegate+QuickActions.swift
//  FoodCollector
//
//  Created by Guy Freedman on 28/05/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    enum Shortcut: String {
        case AddAction = "addAction" , NearYouAction = "nearYouAction"
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        // Handle quick actions
        completionHandler(handleQuickAction(shortcutItem))
        
    }
   
   
    
    @available(iOS 9.0, *)
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.componentsSeparatedByString(".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .AddAction:
               
                FCModel.sharedInstance.shouldPresentAddItem = true
                print("handeled")
                quickActionHandled = true
                
            case .NearYouAction:
                FCModel.sharedInstance.shouldPresentNearYouItem = true
                print("handeled")
                quickActionHandled = true
                
            }
            
        }
        
        return quickActionHandled
    }
}