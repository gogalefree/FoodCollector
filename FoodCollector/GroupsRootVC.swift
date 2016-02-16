//
//  GroupsRootVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 16/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class GroupsRootVC: UIViewController {

    var dataSource          = [Group]()
    var filteredDataSource  = [Group]()
    var isFiltered          = false
    

    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    //MARK: - Actions
    
    @IBAction func createNewGroupTapped() {
    
        let alertTitle = NSLocalizedString("Group Name:", comment: "Message alert title when creating a new group. asks the user to enter a group name")
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .Alert)
        
        let confirmActionTitle = NSLocalizedString("Create", comment: "Alert button title when creating a new group. confirm creation of a new group")
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .Default) { (_) in
            
            if let field = alertController.textFields?[0] {
                // store your data
                let text = field.text
                if let groupName = text && 
                
                
            } else { return }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
        
        
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
