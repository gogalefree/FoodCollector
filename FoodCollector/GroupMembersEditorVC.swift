//
//  GroupMembersEditorVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 17/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

struct GroupMemberData {

    var name        : String
    var phoneNumber : String
    init (name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
    
}

import Foundation
import CoreData
import AddressBook
import AddressBookUI

class GroupMembersEditorVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate, GroupDetilsTVCellDelegate {

    @IBOutlet weak var groupNameLabel   : UILabel!
    @IBOutlet weak var addMemberButton  : UIButton!
    @IBOutlet weak var tableView        : UITableView!
    
    var group   : Group!
    var members = [GroupMemberData]()
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        groupNameLabel.text = group.name
        if members.count == 0 {tableView.alpha = 0}
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: kDoneButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "donePickingMembers")
    }
    
   
    
    //MARK: - TableView DataSource Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupMemberEditorCell") as! GroupMembersEditorTVCell
        cell.delegate = self
        cell.groupMemberData = members[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
                        
            tableView.beginUpdates()
            self.members.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        default:
            break
        }
    }
    
    //MARK: - Actions
    
    @IBAction func addMemberTapped(sender: AnyObject) {
   
        //Show Adrress book
        let addressBookController = ABPeoplePickerNavigationController()
        addressBookController.peoplePickerDelegate = self
        self.presentViewController(addressBookController, animated: true, completion: nil)
    }
    
    func donePickingMembers() {
        
        let membersToSend = GroupMember.createInitialMembers(members, ForGroup: group, createAdmin: true)
        FCModel.sharedInstance.foodCollectorWebServer.postGroupMembers(membersToSend)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didRequestCellDelete() {
        
        let editing = !self.tableView.editing
        self.tableView.setEditing(editing, animated: true)
    }
}
