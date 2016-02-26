//
//  GroupDetailsVC+TableView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 25/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension GroupDetailsVC: GroupDetilsTVCellDelegate {
 
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count > 0 ? 1 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupDetailsMemberCell", forIndexPath: indexPath) as! GroupDetailsMemberTVCell
        cell.isGroupAdmin = self.isUserAdmin
        cell.groupMember = dataSource[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func didRequestCellDelete() {
    
        let editing = !self.membersTableView.editing
        self.membersTableView.setEditing(editing, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            
            let memberToDelete = dataSource[indexPath.row]
            
            tableView.beginUpdates()
            self.dataSource.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            
            //inform server and delete from core data
            print("deleted member: \(memberToDelete.name)")
            GroupMember.deleteGroupMember(memberToDelete, group: group)
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        //if the user is not the admin, he can't edit group members
        if !isUserAdmin {return false}
        
        let admin = self.dataSource.filter { (member) in member.isAdmin!.boolValue == true}
        if admin.count > 0 {
           
            let foundAdmin = admin.first!
            let adminRow = self.dataSource.indexOf(foundAdmin)
            if let adminRowFound = adminRow {
                
                let adminIndexPath = NSIndexPath(forRow: adminRowFound.hashValue, inSection: 0)
                
                if indexPath == adminIndexPath {return false}
            }
        }
    
        return true
    }
    
}