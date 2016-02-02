//
//  FDFacebookLogin.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

class FaceBookLoginManager {

    // Facebook Delegate Methods
    
    class func fetchUserData(loginData: LoginData, completion: (success: Bool) ->Void)
    {
        
        let parameters = ["fields" : "id,name,email,picture.type(large)"]
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
                completion(success: false)
            }
            else {
                
                print("fetched user: \(result)")
                let userName  = result.valueForKey("name") as? String
                let userEmail = result.valueForKey("email") as? String
                let token     = FBSDKAccessToken.currentAccessToken().tokenString
                let userId    = FBSDKAccessToken.currentAccessToken().userID
                
                let urlString = result["picture"]??["data"]??["url"] as? String
                if let urlString = urlString {
                    
                    let url = NSURL(string: urlString)
                    if let data = NSData(contentsOfURL: url!){
                        let image =  UIImage(data: data)
                        loginData.userImage = image
                        NSNotificationCenter.defaultCenter().postNotificationName("IdentityProviderUserImageDownloaded", object: nil)
                    }
                }

                guard let aUserName = userName , aUserEmail = userEmail else { completion(success: false) ; return }
                
                loginData.identityProviderUserName = aUserName
                loginData.identityProviderToken    = token
                loginData.identityProviderUserID   = userId
                loginData.identityProviderEmail    = aUserEmail
                //loginData.isLoggedIn = true
                
                print("User Name is: \(userName)")
                print("User Email is: \(userEmail)")
                print ("accsess token string: " + "\(FBSDKAccessToken.currentAccessToken().tokenString)")
                print ("accsess token userid: " + "\(FBSDKAccessToken.currentAccessToken().userID)")
                print ("accsess token permissions: " + "\(FBSDKAccessToken.currentAccessToken().permissions.description)")

                completion(success: true)
            }
        })
    }
}