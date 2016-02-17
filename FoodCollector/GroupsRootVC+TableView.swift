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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text  = dataSource[indexPath.row].name
        return cell!
    }
}