//
//  LoginRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 30/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class LoginRootVC: UIViewController {
    
    @IBOutlet weak var facebookLoginButton  : UIButton!
    @IBOutlet weak var googleLoginButton    : GIDSignInButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
    }
    
    //MARK: - UI setup
    
   
    //MARK: - Button Actions
    
    @IBAction func facebookButtonClicked() {
        //add activity indicator
        //disable buttons
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            // User is already logged in
            
        }
        else {
            
            
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                
                if (error != nil) {
                    // Process error
                }
                else if result.isCancelled {
                    // Handle cancellations
                }
                else {
                    
                    FCModel.sharedInstance.foodCollectorWebServer.didRequestFacebookLogin({ (success: Bool) -> Void in
                    
                        if success {
                            //stop activity indicator
                            //perform segue to next vc
                        }
                        
                        else {
                            //handle unsuccessful login
                            //present alert
                        }
                   })
                }
            })
        }
    }
    
    @IBAction func googleLoginButtonClicked() {
        //add activity indicator
        //disable buttons
        
        //the login starts automatically and handled in
        //LoginRootVC+GIDSigninDelegate
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
