//
//  ActivityCenterVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19.2.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

let sideMenuBtnTitleMyShares  = NSLocalizedString("My Shares", comment:"Title for a side menu button")
let sideMenuBtnTitleAllEvents = NSLocalizedString("All Events", comment:"Title for a side menu button")
let sideMenuBtnTitleGroups    = NSLocalizedString("Groups", comment:"Title for a side menu button")
let sideMenuBtnTitleSettings  = NSLocalizedString("Settings", comment:"Title for a side menu button")
let sideMenuBtnTitleContactUs = NSLocalizedString("Contact Us", comment:"Title for a side menu button")
let sideMenuBtnTitleAbout     = NSLocalizedString("About", comment:"Title for a side menu button")

class ActivityCenterVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var leftSwipeGesture: UISwipeGestureRecognizer!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userIdentityProviderName: UILabel!
    
    
    @IBOutlet weak var sideMenuTable: UITableView!
    
    var buttunsTitleArray: [String] = [];
    var buttunsImageArray: [UIImage] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("ActivityCenterVC viewDidLoad()")
        leftSwipeGesture.addTarget(self, action: "leftSwipeAction:")
        
        userIdentityProviderName.text = User.sharedInstance.loginData?.identityProviderUserName
        displayUserProfileImage()
        
        sideMenuTable.delegate = self
        sideMenuTable.dataSource = self
        
        createButtunsTitleArray()
        createButtunsImageArray()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    final func leftSwipeAction(recognizer: UISwipeGestureRecognizer) {
        
        let container = self.navigationController?.parentViewController as! FCCollectorContainerController
        container.collectorVCWillSlide()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("buttunsTitleArray.count: \(buttunsTitleArray.count)")
        return buttunsTitleArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 3
        }
        
        return 27
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /// Cells Structure
        // 0 - My Shares
        // 1 - All Events
        // 2 - Groups
        // 3 - -- Seperator --
        // 4 - Settings
        // 5 - Contact Us
        // 6 - About
        
        var cell = tableView.dequeueReusableCellWithIdentifier("sideMenuItemCell") as! sideMenuItemTVCell
        //cell.articles = self.articles?[indexPath.row]
        cell.sideMenuIcon.image = buttunsImageArray[indexPath.row]
        cell.sideMenuTitle.text = buttunsTitleArray[indexPath.row]
        if indexPath.row == 3 {
            cell.backgroundColor = UIColor.grayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // do something
    }
    
    
    
    
    func createButtunsTitleArray() {
        // The empty string in the array represenet the seperator.
        // Without it, the index of the titles in the array will be off sync
        // with the index of the cells in the table.
        
        buttunsTitleArray = [sideMenuBtnTitleMyShares, sideMenuBtnTitleAllEvents, sideMenuBtnTitleGroups, "", sideMenuBtnTitleSettings, sideMenuBtnTitleContactUs, sideMenuBtnTitleAbout]
    }
    
    func createButtunsImageArray() {
        // The empty image in the array represenet the seperator.
        // Without it, the index of the icons in the array will be off sync
        // with the index of the cells in the table.
        
        let sideMenuIconMyShares     = UIImage(named: "MyShares")
        let sideMenuIconAllEvents    = UIImage(named: "AllEvents")
        let sideMenuIconGroups       = UIImage(named: "Groups")
        let sideMenuIconEmptyImage   = UIImage()
        let sideMenuIconSettings     = UIImage(named: "Settings")
        let sideMenuIconContactUs    = UIImage(named: "ContactUs")
        let sideMenuIconAbout        = UIImage(named: "About")
        
        if let image = sideMenuIconMyShares {
            buttunsImageArray.append(image)
        }
        if let image = sideMenuIconAllEvents {
            buttunsImageArray.append(image)
        }
        if let image = sideMenuIconGroups {
            buttunsImageArray.append(image)
        }

        buttunsImageArray.append(sideMenuIconEmptyImage)
        
        if let image = sideMenuIconSettings {
            buttunsImageArray.append(image)
        }
        if let image = sideMenuIconContactUs {
            buttunsImageArray.append(image)
        }
        if let image = sideMenuIconAbout {
            buttunsImageArray.append(image)
        }
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
