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
    
    var loggedIn: Bool {
        return User.sharedInstance.userIsLoggedIn
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) 
        
        switch indexPath.section {
            
        case 0:
            //personal detials
            
            cell.textLabel?.text = NSLocalizedString("Personal Profile", comment: "settings cell title")
            
        case 1:
            //notifications
            
            cell.textLabel?.text = NSLocalizedString("Notifications", comment: "settings cell title")
            
        case 2:
            
            cell.textLabel?.text = NSLocalizedString("Log Out", comment: "settings cell title")
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.textAlignment = .Center
            
            if !loggedIn {
                cell.textLabel?.textColor = UIColor.lightGrayColor()
                cell.userInteractionEnabled = false
            }
            
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
            print("personal profile")
            
        case 1:
            let notoficationsNav = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("NotificationsSettingsNavVC") as! UINavigationController
            let notificationsSettings = notoficationsNav.viewControllers[0] as! NotificationsDistanceVC
            
            self.navigationController?.pushViewController(notificationsSettings, animated: true)
            
        case 2:
            logOut()
            
        default:
            break
        }
    }
    
    func logOut() {
        
        User.sharedInstance.logOut()
        self.tableView.reloadData()
    }
    
    
    @IBAction func dismiss(sender: AnyObject) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
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
