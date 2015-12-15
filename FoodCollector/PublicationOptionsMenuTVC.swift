//
//  PublicationOptionsMenuTVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 04/09/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

protocol PublicationDetailsOptionsMenuPopUpTVCDelegate: NSObjectProtocol{
    func didSelectEditPublicationAction()
    func didSelectTakOffAirPublicationAction()
    func didSelectDeletePublicationAction()
}

class PublicationOptionsMenuTVC: UITableViewController {
    
    weak var delegate: PublicationDetailsOptionsMenuPopUpTVCDelegate!
    
    let kMenuItem1 = NSLocalizedString("Edit", comment:"Publisher top right menu item")
    let kMenuItem2 = NSLocalizedString("Stop Event", comment:"Publisher top right menu item")
    let kMenuItem3 = NSLocalizedString("Delete", comment:"Publisher top right menu item")
    
    let menuImage1 = UIImage(named: "EditButton")
    let menuImage2 = UIImage(named: "TakeOffAirButton")
    let menuImage3 = UIImage(named: "DeleteButton")
    
    var menuTitlesArray: [String] = []
    var menuImagesArray: [UIImage?] = []
    
    var publication: FCPublication?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        createTableData()
        
        self.tableView.registerNib(UINib(nibName: "PublicationOptionsMenuItemCell", bundle: nil), forCellReuseIdentifier: "publicationMenuItemCell")
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        
        tableView.scrollEnabled = false
    }
    
    func createTableData(){
        if (publication!.isOnAir) {
            menuTitlesArray = [kMenuItem1, kMenuItem2, kMenuItem3]
            menuImagesArray = [menuImage1, menuImage2, menuImage3]
        }
        else {
            menuTitlesArray = [kMenuItem1, kMenuItem3]
            menuImagesArray = [menuImage1, menuImage3]
        }
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
        return menuTitlesArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let menuItemCell = tableView.dequeueReusableCellWithIdentifier("publicationMenuItemCell", forIndexPath: indexPath) as! PublicationOptionsMenuItemCell
        menuItemCell.menuItemTitle.text = menuTitlesArray[indexPath.row]
        menuItemCell.menuItemIcon.image = menuImagesArray[indexPath.row]
    
    return menuItemCell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
        switch indexPath.row {
        case 0: // Edit publication
            self.delegate.didSelectEditPublicationAction()
            
        case 1 where (publication!.isOnAir): // Take publication of air
            self.delegate.didSelectTakOffAirPublicationAction()
            
        case 1 where !(publication!.isOnAir): // Delete publication
            //deletePublication()
            self.delegate.didSelectDeletePublicationAction()
            
        case 2: // Delete publication
            //deletePublication()
            self.delegate.didSelectDeletePublicationAction()
            
        default:
            break
        }
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
