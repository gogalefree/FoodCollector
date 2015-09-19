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
    
    private let pListName = "UserData.plist"
    private var userData = [String: String]()
    
    // Key names
    private let userNameKey = "userNameKey"
    private let userPhoneNumberKey = "userPhoneNumberKey"
    
    // class Properties
    private(set) var userName: String? = ""
    private(set) var userPhoneNumber: String? = ""
    
    // 'private' prevents other classes from using the default '()' initializer for this class.
    private init() {
        createInternalUserDataBase()
        setInitialUserData()
    }
    
    private func setInitialUserData() {
        self.userName = getValuForKey(userNameKey)
        self.userPhoneNumber = getValuForKey(userPhoneNumberKey)
    }
    
    private func getValuForKey(key: String) -> String? {
        // this will be impelemnted later to get data from a saved data source.
        // For now the function will return temp data
        
        if (key == userNameKey){
            return "User Name"
        }
        else if (key == userPhoneNumberKey) {
            return "03-333-3333"
        }
        else {
            return nil
        }
    }

    ////===========================================================================
    ////   MARK: - Class Setters
    ////===========================================================================
    
    func setUserName(name: String) {
        self.userName = name
    }
    
    func setUserPhoneNumber(phoneNumber: String) {
        self.userPhoneNumber = phoneNumber
    }
    
    ////===========================================================================
    ////   MARK: - Read & Write data
    ////===========================================================================
    
    private func createInternalUserDataBase(){
        let filePath = FCModel.documentsDirectory().stringByAppendingString(pListName)
        print("USER -> filePath: \(filePath)")
        if !readData(filePath) {
            createEmptyUserData()
        }
        
    }
    
    private func createEmptyUserData() {
        
    }
    
    private func readData(path: String) -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            userData = NSDictionary(contentsOfFile: path) as! [String : String]
            print(userData.description)
            return true
        }
        
        return false
    }
    
    private func writeData() {
        let direcoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = direcoryPath.stringByAppendingString(pListName)
        
        (userData as NSDictionary).writeToFile(path, atomically: true)
        
        print("USER -> Saved plist file in --> \(path)")
    }
    
    
}

