//
//  PublicationAudianceSelectionTVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

let kPublicGroupName = NSLocalizedString("Public", comment:"This is the name of the public group")

class PublicationAudianceSelectionTVC: UITableViewController {
    
    var selectedGroupID = 0
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if cellData != nil {
                selectedGroupID =  cellData?.userData as! Int
            }
        }
    }
    
    var section: Int?
    
    let selectionImage = UIImage(named: "AudianceSelectionUnchecked")
    let selectionImageHighlighted = UIImage(named: "AudianceSelectionChecked")
    var groupNamesArray = [kPublicGroupName]
    var groupIDsArray = [0]
    
    var groupsDataSource = [Group]()
    //var group: Group? = nil
    
    @IBOutlet weak var audianceTitle: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareDataSource()
    }
    
    func prepareDataSource() {
        
        let adminGroupsForUser = Group.adminGroupsForLogedinUser()
        let memberGroupsForUser = Group.groupMemberGroupsForloginUser()
        if let adminGroups = adminGroupsForUser , memberGroups = memberGroupsForUser {
            groupsDataSource = adminGroups + memberGroups
        }
        
        //if let group = Group.initWith("Public", id: 0, adminId: User.sharedInstance.userUniqueID) {
        //    groupsDataSource.insert(group, atIndex: 0)
        //}
        
        for group in groupsDataSource {
            if let groupName = group.name {
                if let groupID = group.id?.integerValue {
                    groupNamesArray.append(groupName)
                    groupIDsArray.append(groupID)
                }
            }
        }
        //print(groupNamesArray)
        //print(groupIDsArray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        // The above has to be uncomment in order for selectRowAtIndexPath to work properly
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupNamesArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("audianceSelectionCell", forIndexPath: indexPath)
        let bgCellView = UIView(frame: cell.frame)
        bgCellView.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.text = groupNamesArray[indexPath.row]
        cell.textLabel?.highlightedTextColor = kNavBarBlueColor
        cell.imageView?.image = selectionImage
        cell.imageView?.highlightedImage = selectionImageHighlighted
        cell.selectedBackgroundView = bgCellView
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        cellData?.userData = groupIDsArray[indexPath.row]
        
        
        //selectedGroupID = groupIDsArray[indexPath.row]
        print("selectedGroupID: \(selectedGroupID)")
        print("cellData.userData: \(cellData!.userData)")
    }
    

    
    /*
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        
    }
*/

    
}
