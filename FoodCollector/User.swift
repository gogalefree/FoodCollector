//
//  User.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19/09/15.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class User {
    // Singleton
    static let sharedInstance = User()
    
    private let pListName = "UserData.plist"
    private var userData = [String: AnyObject]()
    
    // User data key names
    enum UserDataKey: String {
        case ID =                       "id"
        case IdentityProvider =         "identity_provider"
        case IdentityProviderUserID =   "identity_provider_user_id"
        case IdentityProviderToken =    "identity_provider_token"
        case PhoneNumber =              "phone_number"
        case IdentityProviderEmail =    "identity_provider_email"
        case IdentityProviderUserName = "identity_provider_user_name"
        case IsLoggedIn =               "is_logged_in"
        case UUID =                     "active_device_dev_uuid"
        case Ratings =                  "ratings"
        case Credits =                  "credits"
        case Foodies =                  "foodies"
    }
    
    
    // User property values
    var userUniqueID: Int?
    var userIdentityProvider: String?
    var userIdentityProviderUserID: String?
    var userIdentityProviderToken: String?
    var userPhoneNumber: String?
    var userIdentityProviderEmail: String?
    var userIdentityProviderUserName: String?
    var userIsLoggedIn: Bool = false
    var userActiveDeviceDevUUID:String?
    var userRatings: Array<Int> = [0]
    var userCredits: Double = 0.0
    var userFoodies: Int = 0
    
    // Local key names
    private let userNameLocalKey =          "userNameKey"
    private let userPhoneNumberLocalKey =   "userPhoneNumberKey"
    
    // class Properties
    private(set) var userName: String = ""
    //private(set) var userPhoneNumber: String = ""
    
    // 'private' prevents other classes from using the default '()' initializer for this class.
    private init() {
        createInternalUserDataBase()
        setInitialUserData()
    }
    
    private func setInitialUserData() {
        // TODO: Is this method still necessary?
        //self.userName = getValuForKey(userNameKey)
        //self.userPhoneNumber = getValuForKey(userPhoneNumberKey)
    }
    
    private func getValuForKey(key: String) -> String {
        // this will be impelemnted later to get data from a saved data source.
        // For now the function will return data from the internal user data
        
        return userData[key]! as! String
    }

    //===========================================================================
    //   MARK: - Class Setters
    //===========================================================================
    
//    func setUserName(name: String) {
//        self.userName = name
//        updateInternalUserDataBase()
//    }
    
//    func setUserPhoneNumber(phoneNumber: String) {
//        self.userPhoneNumber = phoneNumber
//        updateInternalUserDataBase()
//    }
//    
//    func setUserName(name: String, andPhoneNumber number: String) {
//        setUserName(name)
//        setUserPhoneNumber(number)
//    }
    
    //===========================================================================
    //   MARK: - Read & Write data
    //===========================================================================
    
//    private func createInternalUserDataBase(){
//        let filePath = FCModel.documentsDirectory().stringByAppendingString("/" + pListName)
//        //print("USER -> filePath: \(filePath)")
//        if !readData(filePath) {
//            createEmptyUserData()
//        }
//        
//    }
    
//    private func createEmptyUserData() {
//        userData[userNameKey] = ""
//        userData[userPhoneNumberKey] = ""
//        
//    }
    
    private func setValueInInternalUserData(value: AnyObject, forKey key: UserDataKey) {
        switch key {
        case .ID, .Foodies:
            userData[key.rawValue] = value as! Int
        case .Credits:
            userData[key.rawValue] = value as! Double
        case .IsLoggedIn:
            userData[key.rawValue] = value as! Bool
        case .Ratings:
            userData[key.rawValue] = value as! Array<Int>
        default:
            userData[key.rawValue] = value as! String
        }
        
        //userData[key] = userName
        //userData[userPhoneNumberKey] = userPhoneNumber
        //writeData()
    }
    
    private func readData(path: String) -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            userData = NSDictionary(contentsOfFile: path) as! [String : String]
            //print(userData.description)
            return true
        }
        
        return false
    }
    
    private func writeData() {
        let direcoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = direcoryPath.stringByAppendingString("/" + pListName)
        
        (userData as NSDictionary).writeToFile(path, atomically: true)
        
        //print("USER -> Saved plist file in --> \(path)")
        //print("=========")
        //print(NSDictionary(contentsOfFile: path))
    }
    
    func updateWithLoginData(loginData :LoginData){
        
        //update user properties after login - we only need to update the userId property after we recieve it from the server
        
        //setValueInInternalUserData(LoginData.userId, forKey: .ID)
        //setValueInInternalUserData(LoginData.identityProvider.rawValue, forKey: .IdentityProvider)
        //setValueInInternalUserData(LoginData.identityProviderUserID, forKey: .IdentityProviderUserID)
        //setValueInInternalUserData(LoginData.identityProviderToken, forKey: IdentityProviderToken)
        //setValueInInternalUserData(LoginData.identityProviderEmail, forKey: .IdentityProviderEmail)
        //setValueInInternalUserData(LoginData.identityProviderUserName, forKey: IdentityProviderUserName)
        //setValueInInternalUserData(LoginData.isLoggedIn, forKey: .IsLoggedIn)
        //setValueInInternalUserData(LoginData.active_device_dev_uuid, forKey: .UUID)
    }
}

