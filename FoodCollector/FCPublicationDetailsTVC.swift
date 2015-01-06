//
//  FCPublicationDetailsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationDetailsTVC: UITableViewController {

    var publication: FCPublication?
    var didFetchPublicationReports = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 116
        self.tableView.rowHeight = UITableViewAutomaticDimension
        fetchPublicationReports()
//        fetchPublicationPhoto()
    
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        self.tableView.reloadData()
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
      override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
                var cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationsDetailsTVTitleCell", forIndexPath: indexPath) as FCPublicationsDetailsTVTitleCell
                    cell.publication = self.publication?
            return cell
        }
        else if indexPath.row == 1 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("reportsCell", forIndexPath: indexPath) as FCPublicationDetailsTVReportsCell
            cell.publication = self.publication?
            return cell
            
        }
        else if indexPath.row == 2 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("FCPublicationDetailsPhotoCell", forIndexPath: indexPath) as FCPublicationDetailsPhotoCell
            cell.publication = self.publication?
            return cell
        }
        else {
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "stamCell") as UITableViewCell
            return cell

        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    //MARK: - fetch data for publication
    func fetchPublicationReports() {
    
        //fetch the reports 
        
        //self.didFetchPublicationReports = true
        //reload the reports cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
