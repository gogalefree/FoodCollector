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
    
    //===========================================================================
    //   MARK: - Class Properties and Objects
    //===========================================================================
    
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
    
    // User class Properties with default values
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
    
    // 'private' prevents other classes from using the default '()' initializer for this class.
    private init() {
        //createInternalUserDataBase()
        setInitialUserData()
        calculateUserRating()
        print("userData:\n\(userData.debugDescription)")
        
    }
    
    //===========================================================================
    //   MARK: - Class Properties Functios
    //===========================================================================
    
    private func setInitialUserData() {
        let plistResult = DeviceData.readPlist(plistFileName)
        
        // If the data type is not Dictionary or it is nil, there's no data to work with.
        // In this case, user data already has default values
        if ((plistResult.data != nil) && (plistResult.dataType == .Dictionary)) {
            setUserClassPropertiesFromPlistData(plistResult.data as! NSDictionary)
        }
        else {
            print("No user plist was found. Using default values.")
        }
    }
    
    private func setUserClassPropertiesFromPlistData(data: NSDictionary) {
        setValueInUserClassProperty(getValue(data, forKey: .ID), forKey: .ID)
        setValueInUserClassProperty(getValue(data, forKey: .IdentityProvider), forKey: .IdentityProvider)
        setValueInUserClassProperty(getValue(data, forKey: .IdentityProviderUserID), forKey: .IdentityProviderUserID)
        setValueInUserClassProperty(getValue(data, forKey: .PhoneNumber), forKey: .PhoneNumber)
        setValueInUserClassProperty(getValue(data, forKey: .IdentityProviderEmail), forKey: .IdentityProviderEmail)
        setValueInUserClassProperty(getValue(data, forKey: .IdentityProviderUserName), forKey: .IdentityProviderUserName)
        setValueInUserClassProperty(getValue(data, forKey: .IsLoggedIn), forKey: .IsLoggedIn)
        setValueInUserClassProperty(getValue(data, forKey: .UUID), forKey: .UUID)
        setValueInUserClassProperty(getValue(data, forKey: .Ratings), forKey: .Ratings)
        setValueInUserClassProperty(getValue(data, forKey: .Credits), forKey: .Credits)
        setValueInUserClassProperty(getValue(data, forKey: .Foodies), forKey: .Foodies)
    }
    
    func updateWithLoginData(loginData :LoginData){
        
        //update user properties after login - we only need to update the userId property after we recieve it from the server
        
        // Data recieved from loging identity provider
        setValueInUserClassProperty(loginData.userId!, forKey: .ID)
        setValueInUserClassProperty(loginData.identityProvider.rawValue, forKey: .IdentityProvider)
        setValueInUserClassProperty(loginData.identityProviderUserID!, forKey: .IdentityProviderUserID)
        setValueInUserClassProperty(loginData.identityProviderToken!, forKey: .IdentityProviderToken)
        setValueInUserClassProperty(loginData.identityProviderEmail!, forKey: .IdentityProviderEmail)
        setValueInUserClassProperty(loginData.identityProviderUserName!, forKey: .IdentityProviderUserName)
        setValueInUserClassProperty(loginData.isLoggedIn, forKey: .IsLoggedIn)
        setValueInUserClassProperty(loginData.active_device_dev_uuid!, forKey: .UUID)
        
        writeUserData()
    }
    
    func setValueInUserClassProperty(value: AnyObject, forKey key: UserDataKey) {
        switch key {
        case .ID:
            self.userUniqueID = value as! Int
            
        case .IdentityProvider:
            self.userIdentityProvider = value as! String
            
        case .IdentityProviderUserID:
            self.userIdentityProviderUserID = value as! String
            
        case .IdentityProviderToken:
            self.userIdentityProviderToken = value as! String
            
        case .PhoneNumber:
            self.userPhoneNumber = value as! String
            
        case .IdentityProviderEmail:
            self.userIdentityProviderEmail = value as! String
            
        case .IdentityProviderUserName:
            self.userIdentityProviderUserName = value as! String
            
        case .IsLoggedIn:
            userData[key.rawValue] = value as! Bool
            
        case .UUID:
            self.userActiveDeviceDevUUID = value as! String
            
        case .Ratings:
            userData[key.rawValue] = value as! Array<Int>
            
        case .Credits:
            userData[key.rawValue] = value as! Double
            
        case .Foodies:
            userData[key.rawValue] = value as! Int
        }
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
    //   MARK: - User Data Object Functios
    //===========================================================================
    
    private func updateUserDataWithValuesFromClassProperties(){
        userData[UserDataKey.ID.rawValue] = self.userUniqueID
        userData[UserDataKey.IdentityProvider.rawValue] = self.userIdentityProvider
        userData[UserDataKey.IdentityProviderUserID.rawValue] = self.userIdentityProviderUserID
        userData[UserDataKey.PhoneNumber.rawValue] = self.userPhoneNumber
        userData[UserDataKey.IdentityProviderEmail.rawValue] = self.userIdentityProviderEmail
        userData[UserDataKey.IdentityProviderUserName.rawValue] = self.userIdentityProviderUserName
        userData[UserDataKey.IsLoggedIn.rawValue] = self.userIsLoggedIn
        userData[UserDataKey.UUID.rawValue] = self.userActiveDeviceDevUUID
        userData[UserDataKey.Ratings.rawValue] = self.userRatings
        userData[UserDataKey.Credits.rawValue] = self.userCredits
        userData[UserDataKey.Foodies.rawValue] = self.userFoodies
    }
    
    private func getValue(data: NSDictionary, forKey key: UserDataKey) -> AnyObject {
        
        return data[key.rawValue]!
    }
    
    
    //===========================================================================
    //   MARK: - Read Write Functions
    //===========================================================================
    
    private func writeUserData() {
        updateUserDataWithValuesFromClassProperties()
        DeviceData.writePlist(plistFileName, data: userData)
    }

    
    
    //===========================================================================
    //   MARK: - RREMOVE THESE FUNCTIONS !!!!!
    //===========================================================================
    
    // TODO: I need to remove these 4 methods and update all the files that use them.
    
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
    
    private func readData(path: String) -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            userData = NSDictionary(contentsOfFile: path) as! [String : String]
            //print(userData.description)
            return true
        }
        
        return false
    }


}

