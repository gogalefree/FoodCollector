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
    
    private let plistFileName = "UserData.plist"
    private var userData = [String: AnyObject]()
    
    // TODO: Add userImage key for the User image from the identity provider
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
    private(set) var userUniqueID =                  0
    private(set) var userIdentityProvider =          ""
    private(set) var userIdentityProviderUserID =    ""
    private(set) var userIdentityProviderToken =     ""
    private(set) var userPhoneNumber =               ""
    private(set) var userIdentityProviderEmail =     ""
    private(set) var userIdentityProviderUserName =  ""
    private(set) var userIsLoggedIn =                false
    private(set) var userActiveDeviceDevUUID =       ""
    private(set) var userRatings =                   [0]
    private(set) var userCredits =                   0.0
    private(set) var userFoodies =                   0
    
    private(set) var calculatedUserRating = 0.0
    
    // Local key names
    //private let userNameLocalKey =          "userNameKey"
    //private let userPhoneNumberLocalKey =   "userPhoneNumberKey"
    
    // class Properties
    //private(set) var userName: String = ""
    //private(set) var userPhoneNumber: String = ""
    
    // 'private' prevents other classes from using the default '()' initializer for this class.
    private init() {
        //createInternalUserDataBase()
        setInitialUserData()
        calculateUserRating()
        print("userData:\n\(userData.debugDescription)")
        
    }
    
    private func setInitialUserData() {
        let plistResult = DeviceData.readPlist(plistFileName)
        
        // If the data type is not Dictionary or it is nil, there's no data to work with.
        // In this case, user data already has default values
        if ((plistResult.data != nil) && (plistResult.dataType == .Dictionary)) {
            setUserData(plistResult.data as! NSDictionary)
            createUserDataDictionary()
        }
        else {
            print("No User plist was found")
            createUserDataDictionary()
        }
    }
    
    private func setUserData(data: NSDictionary) {
        self.userUniqueID = getValuForKey(.ID) as! Int
        self.userIdentityProvider = getValuForKey(.IdentityProvider) as! String
        self.userIdentityProviderUserID = getValuForKey(.IdentityProviderUserID) as! String
        self.userPhoneNumber = getValuForKey(.PhoneNumber) as! String
        self.userIdentityProviderEmail = getValuForKey(.IdentityProviderEmail) as! String
        self.userIdentityProviderUserName = getValuForKey(.IdentityProviderUserName) as! String
        self.userIsLoggedIn = getValuForKey(.IsLoggedIn) as! Bool
        self.userActiveDeviceDevUUID = getValuForKey(.UUID) as! String
        
        self.userRatings = getValuForKey(.Ratings) as! [Int]
        self.userCredits = getValuForKey(.Credits) as! Double
        self.userFoodies = getValuForKey(.Foodies) as! Int
        
        
        writeData()
    }
    
    private func getValuForKey(key: UserDataKey) -> AnyObject {
        
        return userData[key.rawValue]!
    }
    
    private func calculateUserRating() {
        let sum = Double(self.userRatings.reduce(0,combine: +))
        let count = Double(self.userRatings.count)
        // Calculate average
        self.calculatedUserRating = (count > 0) ? Double(sum/count) : 0
        // Round to the nearest half (format: 1.0, 1.5)
        self.calculatedUserRating = Double(round(self.calculatedUserRating*2)/2)
    }

    //===========================================================================
    //   MARK: - Class Setters
    //===========================================================================
    
    // TODO: I need to remove these 3 methods and update all the files that use them.
    
    func setUserName(name: String) {
        self.userIdentityProviderUserName = name
        //updateInternalUserDataBase()
    }
    
    func setUserPhoneNumber(phoneNumber: String) {
        self.userPhoneNumber = phoneNumber
        //updateInternalUserDataBase()
    }
    
    func setUserName(name: String, andPhoneNumber number: String) {
        setUserName(name)
        setUserPhoneNumber(number)
    }
    
    //===========================================================================
    //   MARK: - Read & Write data
    //===========================================================================
    
    private func createUserDataDictionary(){
        setValueInInternalUserData(self.userUniqueID, forKey:.ID)
        setValueInInternalUserData(self.userIdentityProvider, forKey:.IdentityProvider)
        setValueInInternalUserData(self.userIdentityProviderUserID, forKey:.IdentityProviderUserID)
        setValueInInternalUserData(self.userPhoneNumber, forKey:.PhoneNumber)
        setValueInInternalUserData(self.userIdentityProviderEmail, forKey:.IdentityProviderEmail)
        setValueInInternalUserData(self.userIdentityProviderUserName, forKey:.IdentityProviderUserName)
        setValueInInternalUserData(self.userIsLoggedIn, forKey:.IsLoggedIn)
        setValueInInternalUserData(self.userActiveDeviceDevUUID, forKey:.UUID)
        setValueInInternalUserData(self.userRatings, forKey: .Ratings)
        setValueInInternalUserData(self.userCredits, forKey: .Credits)
        setValueInInternalUserData(self.userFoodies, forKey: .Foodies)
    }
    
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
        DeviceData.writePlist(plistFileName, data: userData)
    }
    
    func updateWithLoginData(loginData :LoginData){
        
        //update user properties after login - we only need to update the userId property after we recieve it from the server
        
        setValueInInternalUserData(loginData.userId!, forKey: .ID)
        setValueInInternalUserData(loginData.identityProvider.rawValue, forKey: .IdentityProvider)
        setValueInInternalUserData(loginData.identityProviderUserID!, forKey: .IdentityProviderUserID)
        setValueInInternalUserData(loginData.identityProviderToken!, forKey: .IdentityProviderToken)
        setValueInInternalUserData(loginData.identityProviderEmail!, forKey: .IdentityProviderEmail)
        setValueInInternalUserData(loginData.identityProviderUserName!, forKey: .IdentityProviderUserName)
        setValueInInternalUserData(loginData.isLoggedIn, forKey: .IsLoggedIn)
        setValueInInternalUserData(loginData.active_device_dev_uuid!, forKey: .UUID)
        
        setValueInInternalUserData(self.userRatings, forKey: .Ratings)
        setValueInInternalUserData(self.userCredits, forKey: .Credits)
        setValueInInternalUserData(self.userFoodies, forKey: .Foodies)
    
        writeData()
        
        //upload user photo to aws
        let userPhotoUploader = FCUserPhotoFetcher()
        userPhotoUploader.uploadUserPhoto()
    }
}

