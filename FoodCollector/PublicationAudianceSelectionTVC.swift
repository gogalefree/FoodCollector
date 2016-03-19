//
//  PublicationAudianceSelectionTVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 19.3.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

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
    let groupsArray = ["Public", "Friends", "Co-Workers", "Family", "Neighborhood"]
    
    
    @IBOutlet weak var audianceTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
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
        return groupsArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("audianceSelectionCell", forIndexPath: indexPath)
        let bgCellView = UIView(frame: cell.frame)
        bgCellView.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.text = groupsArray[indexPath.row]
        cell.textLabel?.highlightedTextColor = kNavBarBlueColor
        cell.imageView?.image = selectionImage
        cell.imageView?.highlightedImage = selectionImageHighlighted
        cell.selectedBackgroundView = bgCellView
        
        return cell
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
