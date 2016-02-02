//
//  LoginRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 30/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class LoginRootVC: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var facebookLoginButton  : UIButton!
    //@IBOutlet weak var googleLoginButton    : GIDSignInButton!
    
    var phoneNumberLogingViewNavVC: UIViewController!
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        //googleLoginButton.delegate = self
        
        // Phone Number Loging view
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        phoneNumberLogingViewNavVC = loginStoryboard.instantiateViewControllerWithIdentifier("PhoneNumberLoginVC")
    }
    
    //MARK: - UI setup
    
    //TODO: add viewdidlayoutsubviews and set the button to be at top layer.
   
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
                            //TODO: Add segue to phone number VC
                            
                            //self.showPhoneNumberLoginView()
                            //BORIS: Why do you remove this VC now?
                            //you shoukd push the next vc to the navigation controller
                            UIView.animateWithDuration(0.4) { () -> Void in
                                self.navigationController?.pushViewController(self.phoneNumberLogingViewNavVC, animated: true)
                            }
                        }
                        
                        else {
                            //handle unsuccessful login
                            //present alert
                            //TODO: add alert to user and set islogin = false.
                        }
                   })
                }
            })
        }
    }
    
    @IBAction func googleLoginButtonClicked() {
        GIDSignIn.sharedInstance().signIn()
        
        //add activity indicator
        //disable buttons
        
        //the login starts automatically and handled in
        //LoginRootVC+GIDSigninDelegate
        
    }
    
    
    
    @IBAction func cancelRegistration(sender: UIButton) {
        print("cancelRegistration clicked")
        User.sharedInstance.setValueInUserClassProperty(true, forKey: UserDataKey.SkippedLogin)
        UIView.animateWithDuration(0.4) { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
    
    func showPhoneNumberLoginView() {
        //why do you add the phone number vc as a child vc?
        //just push it to the nav controller
        
        print("showPhoneNumberLoginView()")
        
        
        
    }

}
