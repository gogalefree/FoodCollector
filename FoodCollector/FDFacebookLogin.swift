//
//  FDFacebookLogin.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

extension MainActionVC {
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                returnUserData({ (image) -> Void in
                    
                })
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData(completion: (image: UIImage?) ->Void)
    {
        
        let parameters = ["fields" : "id,name,email,picture.type(large)"]

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString? = result.valueForKey("name") as? NSString
                print("User Name is: \(userName)")
                let userEmail : NSString? = result.valueForKey("email") as? NSString
                print("User Email is: \(userEmail)")
                print ("accsess token string: " + "\(FBSDKAccessToken.currentAccessToken().tokenString)")
                print ("accsess token userid: " + "\(FBSDKAccessToken.currentAccessToken().userID)")
                print ("accsess token permissions: " + "\(FBSDKAccessToken.currentAccessToken().permissions.description)")

                let url = result["picture"]??["data"]??["url"] as? String
                if let url = NSURL(string: url!) {
                    if let data = NSData(contentsOfURL: url){
                        let image =  UIImage(data: data)
                        completion(image: image)
                    }
                }

            }
        })
        
    }
    
}