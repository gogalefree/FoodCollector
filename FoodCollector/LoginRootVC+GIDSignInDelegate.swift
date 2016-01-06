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
    //Google Sign in Process
    
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
                loginData.updateWithGoogleUser(user)
                               
                
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