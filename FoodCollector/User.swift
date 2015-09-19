//
//  User.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19/09/15.
//  Copyright © 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class User {
    // Singleton
    static let sharedInstance = User()
    
    var userName: String? = ""
    var userPhoneNumber: String? = ""
    
    // Prevent other classes from using the default '()' initializer for this class.
    private init() {
        setUserData()
    }
    
    private func setUserData() {
        self.userName = getValuForKey("userName")
        self.userPhoneNumber = getValuForKey("userPhoneNumber")
    }
    
    private func getValuForKey(key: String) -> String? {
        // this will be impelemnted later to get data from a saved data source.
        // For now thw function will return temp data
        
        if (key == "userName"){
            return "User Name"
        }
        else if (key == "userPhoneNumber") {
            return "03-333-3333"
        }
        else {
            return nil
        }
    }
}

