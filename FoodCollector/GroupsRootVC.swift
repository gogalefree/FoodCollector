//
//  GroupsRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 16/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class GroupsRootVC: UIViewController {

    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    var dataSource          = [Group]()
    var filteredDataSource  = [Group]()
    var isFiltered          = false
    var group: Group?       = nil

    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDataSource()
        self.tableView.dataSource = self
        self.tableView.delegate   = self
    }

    func prepareDataSource() {
    
        let adminGroupsForUser = Group.adminGroupsForLogedinUser()
        let memberGroupsForUser = Group.groupMemberGroupsForloginUser()
        if let adminGroups = adminGroupsForUser , memberGroups = memberGroupsForUser {
            dataSource = adminGroups + memberGroups
        }
    }
    
    //MARK: - Actions
    
    @IBAction func createNewGroupTapped() {
    
        let alertTitle = NSLocalizedString("Group Name:", comment: "Message alert title when creating a new group. asks the user to enter a group name")
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: kCancelButtonTitle, style: .Cancel) { (_) in }
        let confirmActionTitle = NSLocalizedString("Create", comment: "Alert button title when creating a new group. confirm creation of a new group")
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .Default) { (_) in
            
            if let field = alertController.textFields?[0] {

                let text = field.text
                guard let groupName = text else {return}
                if !groupName.isEmpty {
                    //dismiss group name alert
                    alertController.dismissViewControllerAnimated(true) { () -> Void in
                        
                        //present blocking view
                       // self.presentActivityIndicatorView()
                    }
                    self.beginGroupCreation(groupName)
                }
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func beginGroupCreation(groupName: String) {
    
        var groupData = GroupData()
        groupData.name = groupName
        groupData.creatorId = User.sharedInstance.userUniqueID
        
        
        
        //create the group on the server
        FCModel.sharedInstance.foodCollectorWebServer.postGroup(groupData) { (success, groupData) -> Void in
         
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               
                //dissmiss blocking view
          //      self.hideActivityIndicatorView()
                
                if !success {
                    //show alert
                    self.presentFailureAlert()
                    return
                }


                //create group
                guard let group = Group.initWith((groupData?.name)!, id: (groupData?.id)!, adminId: (groupData?.creatorId)!) else {return}
                //update tableview
                self.dataSource.insert(group, atIndex: 0)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                //push next vc
                self.group = group
                self.performSegueWithIdentifier("showGroupMembersEditorVC", sender: nil)
                
            })
        }
    }
    
    func presentFailureAlert() {
        
        let alertController = UIAlertController(title: kOopsAlertTitle, message: kCommunicationIssueBody, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: kOKButtonTitle, style: .Cancel) { (_) in self.dismissViewControllerAnimated(true, completion: nil)}
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentActivityIndicatorView() {
    
        self.view.bringSubviewToFront(self.activityIndicatorView)
        UIView.animateWithDuration(0.1) { () -> Void in
            self.activityIndicatorView.alpha = 1
        }
    }
    
    func hideActivityIndicatorView() {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.activityIndicatorView.alpha = 0
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: - Navigation

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "showGroupMembersEditorVC" {
            
            let groupMembersEditorVC = segue.destinationViewController as! GroupMembersEditorVC
            groupMembersEditorVC.group = group
        }
    }
    

}
