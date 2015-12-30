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
