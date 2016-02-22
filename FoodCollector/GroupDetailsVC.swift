//
//  GroupDetailsVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 22/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import CoreData

class GroupDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var membersTableView         : UITableView!
    @IBOutlet weak var tableViewTopConstraint   : NSLayoutConstraint!
    @IBOutlet weak var addMemberView            : UIView!
    @IBOutlet weak var groupNameLabel           : UILabel!
    @IBOutlet weak var leaveGroupButton: UIButton!
    var onesToken = 0
    
    var group: Group!
    var dataSource = [GroupMember]()

    func setup() {
 
        dataSource = Array(group.members! as! Set)
        if group.adminUserId?.integerValue == User.sharedInstance.userUniqueID {
            setupForAdmin()
        } else {
            setupForMember()
        }
        
        self.membersTableView.reloadData()
    }

    func setupForAdmin() {
    
        self.leaveGroupButton.alpha = 0
    }
    
    func setupForMember() {
        
        self.leaveGroupButton.alpha = 1
        self.addMemberView.alpha    = 0
        self.tableViewTopConstraint.constant -= CGRectGetHeight(self.addMemberView.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.membersTableView.dataSource  = self
        self.membersTableView.delegate    = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dispatch_once(&onesToken) { () -> Void in
            self.setup()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = dataSource[indexPath.row].name
        return cell!
    }

    @IBAction func addMemberTapped(sender: AnyObject) {
    }
    
    @IBAction func leaveGroupTapped(sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
