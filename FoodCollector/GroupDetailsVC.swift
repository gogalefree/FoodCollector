//
//  GroupDetailsVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 22/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import CoreData
import AddressBook
import AddressBookUI


class GroupDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate {
    
    @IBOutlet weak var membersTableView         : UITableView!
    @IBOutlet weak var tableViewTopConstraint   : NSLayoutConstraint!
    @IBOutlet weak var addMemberView            : UIView!
    @IBOutlet weak var groupNameLabel           : UILabel!
    @IBOutlet weak var leaveGroupButton: UIButton!
    var onesToken = 0
    var isUserAdmin = false
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
        isUserAdmin = true
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
    
    
    @IBAction func addMemberTapped(sender: AnyObject) {
    
        //Show Adrress book
        let addressBookController = ABPeoplePickerNavigationController()
        addressBookController.peoplePickerDelegate = self
        self.presentViewController(addressBookController, animated: true, completion: nil)
    
    }
    
    @IBAction func leaveGroupTapped(sender: AnyObject) {
    
        //delete the gtoup
        let groupToDelete = self.group
        
        let moc = FCModel.dataController.managedObjectContext
        moc.deleteObject(groupToDelete)
        FCModel.dataController.save()
    

        FCModel.sharedInstance.foodCollectorWebServer.deleteGroup(groupToDelete)
        
        //go back to groups vc
        self.navigationController?.popViewControllerAnimated(true)
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
