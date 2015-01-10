//
//  FCActivityCenterTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCActivityCenterTVC: UITableViewController {
    
    var userRegisteredPublications = FCModel.sharedInstance.userRegisteredPublications()
    
    var userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
    
    let collectorTitle = String.localizedStringWithFormat("אוסף", "activity center table view collector section title. means collector")
    
    let publisherTitle = String.localizedStringWithFormat("תורם", "activity center table view publisher section title. means contributer")
    
    let collectorIcon = UIImage(named: "PinGreen.png")
    
    let publisherIcon = UIImage(named: "PinGreen.png")
    
    var selectedIndexPath: NSIndexPath!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 66
        self.tableView.rowHeight = UITableViewAutomaticDimension
    
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.userRegisteredPublications.count + 1
        case 1: return self.userCreatedPublications.count + 1
        default: return 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("FCActivityCenterTVCell", forIndexPath: indexPath) as FCActivityCenterTVCell
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.titleLabel.text = self.collectorTitle
                cell.iconImageView.image = self.collectorIcon
            }
            else {
                let publication = self.userRegisteredPublications[indexPath.row - 1]
                cell.titleLabel.text = publication.title
            }
            
        case 1:
            if indexPath.row == 0 {
                cell.titleLabel.text = self.publisherTitle
                cell.iconImageView.image = self.publisherIcon
            }
            else {
                let publication = self.userCreatedPublications[indexPath.row - 1]
                cell.titleLabel.text = publication.title
            }
            
        default:
            return cell
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

      
        var publication = self.publicationForIndexPath(indexPath)
        let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
        
        publicationDetailsTVC?.publication = publication
        
        publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזור", style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
        let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
        
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }
    
    func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func publicationForIndexPath(indexPath: NSIndexPath)-> FCPublication {
        
        var publication: FCPublication!
        switch indexPath.section {
        case 0:
            publication = self.userRegisteredPublications[indexPath.row - 1] as FCPublication
        case 1:
            publication = self.userCreatedPublications[indexPath.row - 1] as FCPublication
        default:
            publication = nil
        }
        
        return publication
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
