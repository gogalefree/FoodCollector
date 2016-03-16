//
//  ActivityCenterVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19.2.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

let sideMenuBtnTitleMyShares    = NSLocalizedString("My Shares", comment:"Title for a side menu button")
let sideMenuBtnTitleAllEvents   = NSLocalizedString("All Events", comment:"Title for a side menu button")
let sideMenuBtnTitleMapView     = NSLocalizedString("Map View", comment:"Title for a side menu button")
let sideMenuBtnTitleActivityLog = NSLocalizedString("Activity Log", comment:"Title for a side menu button")
let sideMenuBtnTitleGroups      = NSLocalizedString("Groups", comment:"Title for a side menu button")
let sideMenuBtnTitleSettings    = NSLocalizedString("Settings", comment:"Title for a side menu button")
let sideMenuBtnTitleContactUs   = NSLocalizedString("Contact Us", comment:"Title for a side menu button")
let sideMenuBtnTitleAbout       = NSLocalizedString("About", comment:"Title for a side menu button")

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
        leftSwipeGesture.addTarget(self, action: "leftSwipeAction:")
        
        let userName = User.sharedInstance.userIdentityProviderUserName.capitalizedString
        userIdentityProviderName.text = userName
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
        
        let container = self.parentViewController as? FCCollectorContainerController
        container?.collectorVCWillSlide()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttunsTitleArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 5 {
            return 1
        }
        
        return 48
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /// Cells Structure
        // 0 - My Shares
        // 1 - All Events
        // 2 - Map View
        // 3 - Activity Log
        // 4 - Groups
        // 5 - -- Separator --
        // 6 - Settings
        // 7 - Contact Us
        // 8 - About
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sideMenuItemCell") as! sideMenuItemTVCell
        cell.sideMenuIcon.image = buttunsImageArray[indexPath.row]
        cell.sideMenuTitle.text = buttunsTitleArray[indexPath.row]
        if indexPath.row == 5 {
            let separatorLineView = UIView()
            separatorLineView.frame = CGRectMake(10, 0, cell.frame.width-20, cell.frame.height)
            // color = HEX(C8C8C8) -> RGB(200,200,200)
            separatorLineView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            cell.addSubview(separatorLineView)
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
            case 0: // My Shares
                if let mySharesVC = self.storyboard?.instantiateViewControllerWithIdentifier("PublishRootVC") as? FCPublishRootVC {
                    mySharesVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissVC")
                    let nav = UINavigationController(rootViewController: mySharesVC)
                    self.presentViewController(nav, animated: true, completion: nil)
                }
            
            case 1: // All Events
                if let allEventsVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationsTableViewController") as? FCPublicationsTableViewController {
                    allEventsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissVC")
                    let nav = UINavigationController(rootViewController: allEventsVC)
                    self.presentViewController(nav, animated: true, completion: nil)
                }
            
            case 2: // Map View
                let container = self.parentViewController as! FCCollectorContainerController
                container.collectorVCWillSlide()
            
            case 3: // Activity Log
                let activityLogSB = UIStoryboard(name: "ActivityLog", bundle: nil)
                if let activityLogVC = activityLogSB.instantiateInitialViewController() {
                    let nav = UINavigationController(rootViewController: activityLogVC)
                    self.presentViewController(nav, animated: true, completion: nil)
                }
            
            case 4: // Groups
                print("Groups was Taped")
                let groupsStoryBoard = UIStoryboard(name: "Groups", bundle: nil)
                let groupsNavVC = groupsStoryBoard.instantiateInitialViewController() as? UINavigationController
                self.presentViewController(groupsNavVC!, animated: true, completion: nil)
            
            case 6: // Settings
                print("Settings was Taped")
            
                let settingsNav = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! UINavigationController
                self.presentViewController(settingsNav, animated: true, completion: nil)
            
            case 7: // Send Feedback
                presentFeedbackVC()
            
            case 8: // About
                print("About was Taped")
                //if let aboutVC = self.storyboard?.instantiateViewControllerWithIdentifier("AboutVC") as? AboutVC {
                    //aboutVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "dismissVC")
                    //let nav = UINavigationController(rootViewController: aboutVC)
                    //self.navigationController?.presentViewController(nav, animated: true, completion: nil)
                //}
            
            default:
                break
            
        }
    }
    
    
    
    
    func createButtunsTitleArray() {
        // The empty string in the array represenet the seperator.
        // Without it, the index of the titles in the array will be off sync
        // with the index of the cells in the table.
        
        buttunsTitleArray = [sideMenuBtnTitleMyShares, sideMenuBtnTitleAllEvents, sideMenuBtnTitleMapView, sideMenuBtnTitleActivityLog, sideMenuBtnTitleGroups, "", sideMenuBtnTitleSettings, sideMenuBtnTitleContactUs, sideMenuBtnTitleAbout]
    }
    
    func createButtunsImageArray() {
        // The empty image in the array represenet the seperator.
        // Without it, the index of the icons in the array will be off sync
        // with the index of the cells in the table.
        
        let sideMenuIconMyShares     = UIImage(named: "MyShares")
        let sideMenuIconAllEvents    = UIImage(named: "AllEvents")
        let sideMenuIconMapView      = UIImage(named: "MapView")
        let sideMenuIconActivityLog  = UIImage(named: "ActivityLog")
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
        if let image = sideMenuIconMapView {
            buttunsImageArray.append(image)
        }
        if let image = sideMenuIconActivityLog {
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
    
    func displayUserProfileImage() {
        print("profilePic farme: \(profilePic.frame)")
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
    
    final func dismissVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
