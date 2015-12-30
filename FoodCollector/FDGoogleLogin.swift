//
//  FDGoogleLogin.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation

extension MainActionVC: GIDSignInUIDelegate , GIDSignInDelegate {

    
    
    //MARK: - GIDSigninDelegate
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                let userId = user.userID                  // For client-side use only!
                let idToken = user.authentication.idToken // Safe to send to the server
                let name = user.profile.name
                let email = user.profile.email

                
                
                if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
                    
                    let imageURL = user.profile.imageURLWithDimension(100)
                    print(imageURL)
                    
                    if let imageUrl = imageURL {
                        
                        if let data = NSData(contentsOfURL: imageUrl){
                         
                            let image =  UIImage(data: data)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                let view = UIImageView(image: image)
                                view.frame = CGRectMake(159, 159, 100, 100)
                                view.contentMode = UIViewContentMode.ScaleToFill
                                view.center = self.view.center
                                self.view.addSubview(view)
                                self.view.bringSubviewToFront(view)
                            })
                        }

                    }
                }
                
                print("userid: " + userId + "\n" + "token: " + idToken  + "\n" + "name: " + name + "\n" + "email: " + email)
                print("tokenCount: \(idToken.characters.count)")
                // ...
            }
                
                
                
            else {
                print("\(error.localizedDescription)")
            }
            
            
            
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
    

}
