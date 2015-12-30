//
//  LoginRootVC+GIDSignInDelegate.swift
//  FoodCollector
//
//  Created by Guy Freedman on 30/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

extension LoginRootVC: GIDSignInDelegate {
    
    //MARK: - GIDSigninDelegate
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            
            if (error != nil) {
                
                //handle error
                //present alert
                print("Google sign in error: \(error.localizedDescription)")

            }
            
            else {
                
            
                // Perform any operations on signed in user here.
                
                let loginData = LoginData(.Google)
                
                let userId  = user.userID                  // For client-side use only!
                let idToken = user.authentication.idToken  // Safe to send to the server
                let name    = user.profile.name
                let email   = user.profile.email
                
                loginData.identityProviderEmail    = email
                loginData.identityProviderToken    = idToken
                loginData.identityProviderUserName = name
                loginData.identityProviderUserID   = "needs_verification"
                
                
                if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
                    
                    let imageURL = user.profile.imageURLWithDimension(100)
                    print(imageURL)
                    
                    if let imageUrl = imageURL {
                        
                        if let data = NSData(contentsOfURL: imageUrl){
                            
                            let image =  UIImage(data: data)
                            loginData.userImage = image
                        }
                    }
                }
                
                print("userid: " + userId + "\n" + "token: " + idToken  + "\n" + "name: " + name + "\n" + "email: " + email)
                
                FCModel.sharedInstance.foodCollectorWebServer.didRequestGoogleLogin(loginData, completion: { (success) -> Void in
                  
                    if !success {
                        //login failed
                        //present alert
                        
                        return
                    }
                    
                    //successful login
                    //stop activity indicator
                    //perform segue to next vc
                    
                })
            }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
}