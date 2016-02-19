//
//  ActivityCenterVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19.2.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class ActivityCenterVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var leftSwipeGesture: UISwipeGestureRecognizer!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var userIdentityProviderName: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        leftSwipeGesture.addTarget(self, action: "leftSwipeAction:")
        
        userIdentityProviderName.text = User.sharedInstance.loginData?.identityProviderUserName
        displayUserProfileImage()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    final func leftSwipeAction(recognizer: UISwipeGestureRecognizer) {
        
        let container = self.navigationController?.parentViewController as! FCCollectorContainerController
        container.collectorVCWillSlide()
    }
    
    func displayUserProfileImage() {
        profilePic.image = User.sharedInstance.loginData?.userImage ?? User.sharedInstance.userImage
        profilePic.layer.cornerRadius = CGRectGetWidth(profilePic.frame)/2
        profilePic.layer.masksToBounds = true
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
