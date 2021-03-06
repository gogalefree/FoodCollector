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
    @IBOutlet weak var skipButton: UIButton!
    
    
    var phoneNumberLogingViewNavVC: UIViewController!
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        //googleLoginButton.delegate = self
        
        // Add underline to the skip button text
        addAttributedTextToSkipButton()
        
        // Phone Number Loging view
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        phoneNumberLogingViewNavVC = loginStoryboard.instantiateViewControllerWithIdentifier("PhoneNumberLoginVC")
    }
    
    //MARK: - UI setup
    func addAttributedTextToSkipButton() {
        let textColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        var attrs = [NSForegroundColorAttributeName: textColor, NSUnderlineStyleAttributeName: 1]
        
        if let font = UIFont(name: "Helvetica-Light", size: 14.0) {
            print("Helvetica-Light found")
            attrs.updateValue(font, forKey: NSFontAttributeName)
            //attrs.updateValue(textColor, forKey: NSForegroundColorAttributeName)
        }
        
        let buttonTitleString = NSAttributedString(string:kSkipSignInButtonTitle, attributes:attrs)
        skipButton.setAttributedTitle(buttonTitleString, forState: .Normal)
    }
    
    //TODO: add viewdidlayoutsubviews and set the button to be at top layer.
   
    //MARK: - Button Actions
    
    @IBAction func facebookButtonClicked() {
        //add activity indicator
        //disable buttons
        
        //if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            // User is already logged in
            
            
        //}
        //else {
            
            
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
                            
                            UIView.animateWithDuration(0.4) { () -> Void in
                                self.navigationController?.pushViewController(self.phoneNumberLogingViewNavVC, animated: true)
                            }
                        }
                        
                        else {
                            //handle unsuccessful login
                            //present alert
                            //TODO: (Boris) add alert to user and set islogin = false, skippedLogin=true, close presented view.
                        }
                   })
                }
            })
        //}
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
