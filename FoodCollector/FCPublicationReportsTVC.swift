//
//  FCPublicationReportsTVCTableViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/19/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationReportsTVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var publication: Publication!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }


    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publication.reports?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("publicationReportsTVCell", forIndexPath: indexPath) as! FCPublicationReporetsTVCell
        let reportsArray = Array(self.publication.reports!) as! [PublicationReport]
        cell.report = reportsArray[indexPath.row]
        return cell
    }
    
    @IBAction func dismiss() {
     
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
