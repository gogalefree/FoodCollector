//
//  AboutUsTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 23/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class AboutUsTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 120
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 120
        default:
            return UITableViewAutomaticDimension
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("aboutUsLikeCell", forIndexPath: indexPath) as! AboutUsLikeCell
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("aboutUsTextCell", forIndexPath: indexPath) as! AboutUsTextCell
            return cell
            
        default:
            break

        }
        
        return UITableViewCell()
        
    }
    

    @IBAction func dismiss(sender: AnyObject) {
    
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    
}
