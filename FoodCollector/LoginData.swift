//
//  LoginData.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

class LoginData: NSObject {

    enum IdentityProvider: String {
        case Facebook = "facebook", Google = "google", Foodonet   = "foodonet"
    }
    
    var userId                  :Int?
    var identityProvider        :IdentityProvider
    var identityProviderUserID  :String?
    var identityProviderUserName:String?
    var identityProviderToken   :String?
    var phoneNumber             :String
    var identityProviderEmail   :String?
    var isLoggedIn              :Bool = false
    var active_device_dev_uuid  :String? = FCModel.sharedInstance.deviceUUID
    var userImage               :UIImage?
    
    
    init(_ identityProvider: IdentityProvider) {
        
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
        
        let
        params : [String: AnyObject] = ["user" :[
            "identity_provider"             : identityProvider.rawValue,
            "identity_provider_user_id"     : identityProviderUserID,
            "identity_provider_token"       : identityProviderToken,
            "phone_number"                  : phoneNumber,
            "identity_provider_email"       : identityProviderEmail,
            "identity_provider_user_name"   : identityProviderUserName,
            "is_logged_in"                  : isLoggedIn,
            "active_device_dev_uuid"        : active_device_dev_uuid]]
        
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
        self.identityProviderUserID   = "needs_verification"
        
        print("userid: " + userId + "\n" + "token: " + idToken  + "\n" + "name: " + name + "\n" + "email: " + email)
        
        if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
            
            let imageURL = user.profile.imageURLWithDimension(100)
            print(imageURL)
            
            if let imageUrl = imageURL {
                
                if let data = NSData(contentsOfURL: imageUrl){
                    
                    let image =  UIImage(data: data)
                    self.userImage = image
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
