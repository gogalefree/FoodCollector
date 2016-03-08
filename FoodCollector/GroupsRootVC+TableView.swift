//
//  GroupsRootVC+TableView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 17/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import UIKit

extension GroupsRootVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return dataSource.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupsRootvcCell", forIndexPath: indexPath) as? GroupsRootvcTVCell
        cell?.group = self.dataSource[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedIndexPath = indexPath
        self.performSegueWithIdentifier("showGroupDetails", sender: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            
            self.indexPathToDelete = indexPath
            confirmDelete(indexPath)
            
        default:
            break
        }
    }
    
    func confirmDelete(indexPath: NSIndexPath) {
        
        let groupToDelete = dataSource[indexPath.row]
        let alert = UIAlertController(title: "Delete Group", message: "Are you sure you want to permanently delete \(groupToDelete.name)?", preferredStyle: .ActionSheet)
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteGroup)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteGroup)
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleDeleteGroup(alertAction: UIAlertAction!) {
        let groupToDelete = dataSource[indexPathToDelete!.row]

        self.tableView.beginUpdates()
        self.dataSource.removeAtIndex(indexPathToDelete!.row)
        self.tableView.deleteRowsAtIndexPaths([indexPathToDelete!], withRowAnimation: .Fade)
        tableView.endUpdates()
        
        let moc = FCModel.dataController.managedObjectContext
        moc.deleteObject(groupToDelete)
        FCModel.dataController.save()
    

        //inform server
        FCModel.sharedInstance.foodCollectorWebServer.deleteGroup(groupToDelete)
        
        //TODO: Take the publication associated with this group off air
    }
    
    func cancelDeleteGroup(alertAction: UIAlertAction!) {
        
    }

}