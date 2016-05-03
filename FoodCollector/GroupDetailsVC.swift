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
 
        //sort with admin first
        dataSource = Array(group.members! as! Set<GroupMember>).sort { (member1, member2) in member1.isAdmin?.boolValue.hashValue > member2.isAdmin?.boolValue.hashValue }
        
        self.groupNameLabel.text = group.name
        if group.adminUserId?.integerValue == User.sharedInstance.userUniqueID {
            setupForAdmin()
        } else {
            setupForMember()
        }
        
        self.membersTableView.reloadData()
    }

    func setupForAdmin() {
    
        self.leaveGroupButton.alpha = 1
        self.leaveGroupButton.titleLabel?.textAlignment = .Center
        isUserAdmin = true
    }
    
    func setupForMember() {
        
        self.leaveGroupButton.alpha = 1
        self.leaveGroupButton.titleLabel?.textAlignment = .Center
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
        
        //when a user wants to leave a group:
        //1. infrom the server to delete the user as a group member from the group
        //2. delete the group from the current device. this will result with the deletion of all group members
        
        let memberToDelete = self.group.members!.filter { (member) -> Bool in
            let aMember = member as? GroupMember
            return aMember?.userId?.integerValue == User.sharedInstance.userUniqueID
        }
    
        if let foundMemeber = memberToDelete.first as? GroupMember {
            print("member to delete id: \(foundMemeber.userId?.integerValue)")
            print("member to delete name: \(foundMemeber.name)")
            FCModel.sharedInstance.foodCollectorWebServer.deleteGroupMember(foundMemeber)
        }

        //delete the gtoup locally
        let groupToDelete = self.group
        
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        moc.deleteObject(groupToDelete)
        FCModel.sharedInstance.dataController.save()
            
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
