//
//  User.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19/09/15.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

// User data key names
enum UserDataKey: String {
    case ID =                               "id"
    case IdentityProvider =                 "identity_provider"
    case IdentityProviderUserID =           "identity_provider_user_id"
    case IdentityProviderToken =            "identity_provider_token"
    case PhoneNumber =                      "phone_number"
    case IdentityProviderEmail =            "identity_provider_email"
    case IdentityProviderUserName =         "identity_provider_user_name"
    case IsLoggedIn =                       "is_logged_in"
    case UUID =                             "active_device_dev_uuid"
    case Ratings =                          "ratings"
    case Credits =                          "credits"
    case Foodies =                          "foodies"
    case ImageName =                        "user_image_name"
    case SkippedLogin =                     "skipped_login"
    case CompletedIdentityProviderLogin =   "completed_identity_provider_login"
    case Image =                            "user_image"
}

class User {
    // Singleton
    static let sharedInstance = User()
    
    //===========================================================================
    //   MARK: - Class Properties and Objects
    //===========================================================================
    
    private let plistFileName = "UserData.plist"
    private let defaultUserImageFileName = "user"
    private let defaultUserImageFileNameSuffix = ".jpg"
    private var userData = [String: AnyObject]()
    var loginData: LoginData?
    // TODO: Add userImage key for the User image from the identity provider
    
    
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
    
    private(set) var userImage:UIImage?
    private(set) var userImageName =        ""
    private(set) var calculatedUserRating = 0.0
    private(set) var userSkippedLogin =     false
    private(set) var userCompletedIdentityProviderLogin = false
    
    let settings = UserSettings()
    
    // 'private' prevents other classes from using the default '()' initializer for this class.
    private init() {
        setInitialUserData()
        calculateUserRating()
        print("userData:\n\(userData.debugDescription)")
        
    }
    
    //===========================================================================
    //   MARK: - Class Properties Functios
    //===========================================================================
    
    private func setInitialUserData() {
        let plistResult = DeviceData.readPlist(plistFileName)
        print("plist detailes:")
        print(plistResult)
        // If the data type is not Dictionary or it is nil, there's no data to work with.
        // In this case, user data already has default values
        if ((plistResult.data != nil) && (plistResult.dataType == .Dictionary)) {
            setUserClassPropertiesFromPlistData(plistResult.data as! NSDictionary)
            
        }
        else {
            print("No user plist was found. Using default values.")
        }
        
        setUserImage()
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
        setValueInUserClassProperty(getValue(data, forKey: .ImageName), forKey: .ImageName)
        setValueInUserClassProperty(getValue(data, forKey: .SkippedLogin), forKey: .SkippedLogin)
    }
    
    func updateWithLoginData(){
        
        guard let loginData = self.loginData else {return}
        
        print("start updateWithLoginData")
        print("self.userIsLoggedIn: \(self.userIsLoggedIn)")
        print("self.userSkippedLogin: \(self.userSkippedLogin)")
        print("self.userCompletedIdentityProviderLogin: \(self.userCompletedIdentityProviderLogin)")
        //update user properties after login - we only need to update the userId property after we recieve it from the server
        
        // Data recieved from loging identity provider
        if let id = loginData.userId {
            setValueInUserClassProperty(id, forKey: .ID)
        }
        if let userID = loginData.identityProviderUserID {
            setValueInUserClassProperty(userID, forKey: .IdentityProviderUserID)
        }
        if let token = loginData.identityProviderToken {
            setValueInUserClassProperty(token, forKey: .IdentityProviderToken)
        }
        if let email = loginData.identityProviderEmail {
            setValueInUserClassProperty(email, forKey: .IdentityProviderEmail)
        }
        if let name = loginData.identityProviderUserName {
            setValueInUserClassProperty(name, forKey: .IdentityProviderUserName)
        }
        if let uuid = loginData.active_device_dev_uuid {
            setValueInUserClassProperty(uuid, forKey: .UUID)
        }
        
        setValueInUserClassProperty(loginData.identityProvider.rawValue, forKey: .IdentityProvider)
        if (loginData.isLoggedIn) {
            // If loginData.isLoggedIn == true, it means the user has successfully completed the
            // Identity Provider login. It DOES NOT mean that the entire login process was successful!
            // Only after the user registered his phone number, the login is successful.
            print("loginData.isLoggedIn: \(loginData.isLoggedIn)")
            setValueInUserClassProperty(true, forKey: .CompletedIdentityProviderLogin)
            print("")
        }
        
        
        // Image data from loging identity provider
        if let image = loginData.userImage {
            print("Image user is present!!!!")
            self.userImage = image
            DeviceData.writeImage(image, imageName: self.getFullUserIamgeName())
            let fullImageName = getFullUserIamgeName()
            if (DeviceData.writeImage(self.userImage!, imageName: fullImageName)) {
                setValueInUserClassProperty(fullImageName, forKey: .ImageName)
            }
            
            //upload user photo to amazon
            let userPhotoUploader = FCUserPhotoFetcher()
            userPhotoUploader.uploadUserPhoto() 
        }
        //else {
        //    print("No User Image!!!!")
        //}
        
        writeUserData()
        
        print("end updateWithLoginData")
        print("self.userIsLoggedIn: \(self.userIsLoggedIn)")
        print("self.userSkippedLogin: \(self.userSkippedLogin)")
        print("self.userCompletedIdentityProviderLogin: \(self.userCompletedIdentityProviderLogin)")
    }
    
    func setValueInUserClassProperty(value: AnyObject?, forKey key: UserDataKey) {
        print("Key: \(key) ->  Value: \(value)")
        switch key {
        case .ID:
            self.userUniqueID = value as? Int ?? 0
            
        case .IdentityProvider:
            self.userIdentityProvider = value as? String ?? ""
            
        case .IdentityProviderUserID:
            self.userIdentityProviderUserID = value as? String ?? ""
            
        case .IdentityProviderToken:
            self.userIdentityProviderToken = value as? String ?? ""
            
        case .PhoneNumber:
            self.userPhoneNumber = value as? String ?? ""
            
        case .IdentityProviderEmail:
            self.userIdentityProviderEmail = value as? String ?? ""
            
        case .IdentityProviderUserName:
            self.userIdentityProviderUserName = value as? String ?? ""
            
        case .IsLoggedIn:
            self.userIsLoggedIn = value as? Bool ?? false
        case .UUID:
            self.userActiveDeviceDevUUID = value as? String ?? ""
            
        case .Ratings:
            self.userRatings = value as? Array<Int> ?? [0]
            
        case .Credits:
            self.userCredits = value as? Double ?? 0.0
            
        case .Foodies:
            self.userFoodies = value as? Int ?? 0
        
        case .ImageName:
            self.userImageName = value as? String ?? ""
        
        case .SkippedLogin:
            self.userSkippedLogin = value as? Bool ?? false
        
        case .CompletedIdentityProviderLogin:
            self.userCompletedIdentityProviderLogin = value as? Bool ?? false
            
        case .Image:
            self.userImage = value as? UIImage ?? UIImage(named: "ProfilePic")!
        }
        
        
        writeUserData()
    }

    private func calculateUserRating() {
        let sum = Double(self.userRatings.reduce(0,combine: +))
        let count = Double(self.userRatings.count)
        // Calculate average
        self.calculatedUserRating = (count > 0) ? Double(sum/count) : 0
        // Round to the nearest half (format: 1.0, 1.5)
        self.calculatedUserRating = Double(round(self.calculatedUserRating*2)/2)
    }
    
    private func setUserImage() {
        
        if (self.userImageName == "") {
            self.userImage = UIImage(named: "ProfilePic")
        }
        else {
            // use an existing image from documents diretory (as listed in UserData.plist)
            let path = FCModel.documentsDirectory().stringByAppendingString("/" + self.userImageName)
            loadImageFromPath(path)
        }
    }
    
    private func loadImageFromPath(path: String) {
        self.userImage = UIImage(contentsOfFile: path)!
    }
    
    func getFullUserIamgeName() -> String {
        return self.defaultUserImageFileName + String(self.userUniqueID) + self.defaultUserImageFileNameSuffix
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
        userData[UserDataKey.ImageName.rawValue] = self.userImageName
        userData[UserDataKey.SkippedLogin.rawValue] = self.userSkippedLogin
        userData[UserDataKey.CompletedIdentityProviderLogin.rawValue] = self.userCompletedIdentityProviderLogin
    }
    
    private func getValue(data: NSDictionary, forKey key: UserDataKey) -> AnyObject? {
        
        return data[key.rawValue]
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

