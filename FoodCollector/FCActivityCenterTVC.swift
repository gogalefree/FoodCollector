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
    
    let collectorTitle = String.localizedStringWithFormat("בדרך לקחת", "activity center table view collector section title. means collector")
    let publisherTitle = String.localizedStringWithFormat("שיתופים פעילים", "activity center table view publisher section title. means contributer")
    
    let collectorIcon = UIImage(named: "Collect.png")
    
    let publisherIcon = UIImage(named: "Donate.png")
    
    var selectedIndexPath: NSIndexPath!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 66
        self.tableView.rowHeight = UITableViewAutomaticDimension
        reload()
    }
    
    func reload() {
        self.userRegisteredPublications = FCModel.sharedInstance.userRegisteredPublications()
        self.userCreatedPublications = FCModel.sharedInstance.userCreatedPublications
        self.removeExpiredUserCreatedPublications()
        self.tableView.reloadData()
    }
    
    func removeExpiredUserCreatedPublications() {
        
        var indexesToRemove = [Int]()
        
        for (index ,userCreatedPublication) in enumerate(self.userCreatedPublications){
           
            if !userCreatedPublication.isOnAir || FCDateFunctions.PublicationDidExpired(userCreatedPublication.endingDate){
                    indexesToRemove.append(index)
            }
        }
        
        for (index, indexToRemove) in enumerate(indexesToRemove) {
            let removalIndex = indexToRemove - index
            self.userCreatedPublications.removeAtIndex(removalIndex)
        }
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
        
        let colorView = UIView()
        colorView.backgroundColor = UIColor.blackColor()
        cell.selectedBackgroundView = colorView

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.titleLabel.text = self.collectorTitle
                cell.iconImageView.image = self.collectorIcon
                cell.userInteractionEnabled = false
            }
            else {
                let publication = self.userRegisteredPublications[indexPath.row - 1]
                cell.titleLabel.text = publication.title
            }
            
        case 1:
            if indexPath.row == 0 {
                cell.titleLabel.text = self.publisherTitle
                cell.iconImageView.image = self.publisherIcon
                cell.userInteractionEnabled = false

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

        if indexPath.row == 0 {return}
        var publication = self.publicationForIndexPath(indexPath)
        let title = titleForIndexPath(indexPath)
        
        switch indexPath.section {
        case 0:
            let publicationDetailsTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationDetailsTVC") as? FCPublicationDetailsTVC
            publicationDetailsTVC?.title = title
            publicationDetailsTVC?.publication = publication
            
            publicationDetailsTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזור", style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            let nav = UINavigationController(rootViewController: publicationDetailsTVC!)
            
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            
        case 1:
        
            let publicationEditorTVC = self.storyboard?.instantiateViewControllerWithIdentifier("FCPublicationEditorTVC") as? FCPublicationEditorTVC
            publicationEditorTVC?.setupWithState(.ActivityCenter, publication: publication)
            publicationEditorTVC?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "חזור", style: UIBarButtonItemStyle.Done, target: self, action: "dismissDetailVC")
            publicationEditorTVC?.title = title
            let nav = UINavigationController(rootViewController: publicationEditorTVC!)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        
        default: break
        
        }
    }
    
    func dismissDetailVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func titleForIndexPath(indexPath:NSIndexPath) -> String{
        if indexPath.section == 0 {return collectorTitle}
        else {return publisherTitle}
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
