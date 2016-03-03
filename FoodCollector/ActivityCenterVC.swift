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
    
    @IBAction func menuViewTapped(sender: UITapGestureRecognizer) {
        
        switch sender.view?.tag {
        case .Some(10101):
            // My Shares
            //self.tabBarController?.selectedIndex = 1
            print("my shares clicked: " + __FUNCTION__ )
        case .Some(10102):
            print("My Picups was Taped" + __FUNCTION__)
            let container = self.navigationController?.parentViewController as! FCCollectorContainerController
            container.collectorVCWillSlide()
            //performSegueWithIdentifier("presentPublicationsTVC", sender: nil)
            
            let activityLogSB = UIStoryboard(name: "ActivityLog", bundle: nil)
            let activityLogNav = activityLogSB.instantiateInitialViewController() as! UINavigationController
            self.navigationController?.presentViewController(activityLogNav, animated: true, completion: nil)
            
        case .Some(10103):
            print("Groups was Taped")
            let groupsStoryBoard = UIStoryboard(name: "Groups", bundle: nil)
            let groupsNavVC = groupsStoryBoard.instantiateInitialViewController() as? UINavigationController
            self.presentViewController(groupsNavVC!, animated: true, completion: nil)
        case .Some(10104):
            print("Settings was Taped")
        case .Some(10105):
            presentFeedbackVC()
        case .Some(10106):
            // About
            if let aboutVC = self.storyboard?.instantiateViewControllerWithIdentifier("AboutVC") as? AboutVC {
                print("AboutVC")
                aboutVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissAboutVC")
                let nav = UINavigationController(rootViewController: aboutVC)
                self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    private func displayUserProfileImage() {
        profilePic.image = User.sharedInstance.loginData?.userImage ?? User.sharedInstance.userImage
        profilePic.layer.cornerRadius = CGRectGetWidth(profilePic.frame)/2
        profilePic.layer.masksToBounds = true
    }
    
    private func presentFeedbackVC(){
        let feedbackNavVC = self.storyboard?.instantiateViewControllerWithIdentifier("feedbackvc") as! FeedbacksVCViewController
        feedbackNavVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        feedbackNavVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.parentViewController?.parentViewController?.presentViewController(feedbackNavVC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    final func dismissAboutVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
