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

class GroupMembersEditorVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate {

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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = members[indexPath.row].name
        return cell!
 
    }
    
    //MARK: - Actions
    
    @IBAction func addMemberTapped(sender: AnyObject) {
   
        //Show Adrress book
        let addressBookController = ABPeoplePickerNavigationController()
        addressBookController.peoplePickerDelegate = self
        self.presentViewController(addressBookController, animated: true, completion: nil)
    }
    
    func donePickingMembers() {
        
        let membersToSend = GroupMember.createInitialMembers(members, ForGroup: group)
        FCModel.sharedInstance.foodCollectorWebServer.postGroupMembers(membersToSend)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
