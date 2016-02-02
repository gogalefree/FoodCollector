//
//  LoginData.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

let userKey                     = "user"
let userIdKey                   = "id"
let indentityProviderKey        = "identity_provider"
let identityProviderUserIdKey   = "identity_provider_user_id"
let identityProviderTokenKey    = "identity_provider_token"
let phoneNumberKey              = "phone_number"
let identityProviderEmailKey    = "identity_provider_email"
let identityProviderUserNameKey = "identity_provider_user_name"
let isLoggedInKey               = "is_logged_in"
let activeDeviceDevUuidKey      = "active_device_dev_uuid"

enum LoginIdentityProvider: String {
    case Facebook = "facebook", Google = "google", Foodonet   = "foodonet"
}

class LoginData: NSObject {    
    
    var userId                  :Int?
    var identityProvider        :LoginIdentityProvider
    var identityProviderUserID  :String?
    var identityProviderUserName:String?
    var identityProviderToken   :String?
    var phoneNumber             :String
    var identityProviderEmail   :String?
    var isLoggedIn              :Bool = false
    var active_device_dev_uuid  :String? = FCModel.sharedInstance.deviceUUID
    var userImage               :UIImage?
    
    
    init(_ identityProvider: LoginIdentityProvider) {
        
        self.identityProvider   = identityProvider
        self.phoneNumber        = User.sharedInstance.userPhoneNumber
        super.init()
    }
    
    func jsonToSend() -> NSData?{
        
        guard let
            identityProviderUserID = identityProviderUserID,
            identityProviderToken = identityProviderToken,
            identityProviderEmail = identityProviderEmail,
            identityProviderUserName = identityProviderUserName,
            active_device_dev_uuid = active_device_dev_uuid else { return nil }
        
        var
        params : [String: AnyObject] = [userKey :[
            indentityProviderKey            : identityProvider.rawValue,
            identityProviderUserIdKey       : identityProviderUserID,
            identityProviderTokenKey        : identityProviderToken,
            phoneNumberKey                  : phoneNumber,
            identityProviderEmailKey        : identityProviderEmail,
            identityProviderUserNameKey     : identityProviderUserName,
            isLoggedInKey                   : true,
            activeDeviceDevUuidKey          : active_device_dev_uuid]]
        
        //if the identity provider is google we dont sent the identity provider user id
        //the server should extract it from the token
        if self.identityProvider == .Google { params[identityProviderUserIdKey] = "needs_verification_by_server"}
        return try? NSJSONSerialization.dataWithJSONObject(params, options: [])
        
    }
    
    func updateWithGoogleUser(user: GIDGoogleUser) {
        
        let userId  = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken  // Safe to send to the server
        let name    = user.profile.name
        let email   = user.profile.email
        
        self.identityProviderEmail    = email
        self.identityProviderToken    = idToken
        self.identityProviderUserName = name
        self.identityProviderUserID   = userId
        
        print("userid: " + userId + "\n" + "token: " + idToken  + "\n" + "name: " + name + "\n" + "email: " + email)
        
        if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
            
            let imageURL = user.profile.imageURLWithDimension(100)
            print(imageURL)
            
            if let imageUrl = imageURL {
                
                if let data = NSData(contentsOfURL: imageUrl){
                    
                    let image =  UIImage(data: data)
                    self.userImage = image
                NSNotificationCenter.defaultCenter().postNotificationName("IdentityProviderUserImageDownloaded", object: nil)
                }
            }
        }
    }
    
    //this is a helper method
    //will be removed after server integration
    func prepareMockData() {
        
        identityProviderUserID      = "someIdentityProviderUserID"
        identityProviderUserName    = "someIdentityProviderUserName"
        identityProviderToken       = "someIdentityProviderToken"
        identityProviderEmail       = "some@identityProviderEmail"
        isLoggedIn                  = true
    }
}
