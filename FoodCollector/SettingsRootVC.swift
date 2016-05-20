//
//  SettingsRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10/03/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class SettingsRootVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    let bellIcon = UIImage(named: "Bell")
    let userIcon = UIImage(named: "User_icon")
    
    var loggedIn: Bool {
        return User.sharedInstance.userIsLoggedIn
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) 
        cell.textLabel?.textColor = kNavBarBlueColor
        
        switch indexPath.section {
            
        case 0:
            //personal detials
            
            cell.textLabel?.text = NSLocalizedString("Profile Settings", comment: "settings cell title")
            cell.imageView?.image = userIcon
            
        case 1:
            //notifications
            
            cell.textLabel?.text = NSLocalizedString("Notifications", comment: "settings cell title")
            cell.imageView?.image = bellIcon

        default:
            break
        }
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
            
        case 0:
            //personal profile
            
            if loggedIn {
                let userProfileTVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserProfileTVC") as! UserProfileTVC
                self.navigationController?.pushViewController(userProfileTVC, animated: true)
            }
            
        case 1:
            let notoficationsNav = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("NotificationsSettingsNavVC") as! UINavigationController
            let notificationsSettings = notoficationsNav.viewControllers[0] as! NotificationsDistanceVC
            
            self.navigationController?.pushViewController(notificationsSettings, animated: true)
            
        default:
            break
        }
    }
    
    @IBAction func logoutActionTapped(sender: AnyObject) {
    
        logOut()
        dismiss(self)
        FCModel.sharedInstance.userDidLogout()
    }
    
    func logOut() {
        
        //clear logs
        ActivityLog.deleteLogsAfetrLogout()
        User.sharedInstance.logOut()
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        //TODO: Add logout with foodonet server
    }
    
    
    @IBAction func dismiss(sender: AnyObject) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
}
