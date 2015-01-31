//
//  FCPublicationDetailsTVReportsCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/3/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationDetailsTVReportsCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var noReports = false
    var heightConstraint : NSLayoutConstraint!
    
    var publication: FCPublication? {
        didSet{
            if let publication = self.publication? {
                self.setup(publication)
            }
        }
    }
    
    func setup(publication: FCPublication) {
        
        self.noReports = true
        
        if publication.reportsForPublication.count != 0 {
                self.noReports = false
                FCDateFunctions.sortPublicationReportsByDate(publication)
                self.tableView.reloadData()
        }
        
       
        
       // let size = self.sizeThatFits(CGSizeMake(self.bounds.width, 0))
       // self.heightConstraint.constant = size.height
       // self.addHeightConstarint(size.height)
    }
 
    
    //MARK: - tableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = self.publication?.reportsForPublication.count
        if let num = num {
            if num < 3 {
                //if there are no reports - return 1
                //if reports.count > 3 return 3
                //else return reports.count
                return  max(1, num)
            }
            return 3
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("singleReportCell") as UITableViewCell as FCPublicationSingleReportCell
        
        if self.noReports {
            cell.noReports()
            return cell
        }

        let report = self.publication?.reportsForPublication[indexPath.row] as FCOnSpotPublicationReport!
        let typeOfCollecting = self.publication?.typeOfCollecting
        
        cell.typeOfCollecting = typeOfCollecting!
        cell.report = report
        return cell
    }
    
//    override func sizeThatFits(size: CGSize) -> CGSize {
//    
//        if self.noReports {
//            let cellSize = CGSizeMake(size.width, 44)
//            return cellSize
//        }
//    
//        var itemsCounter = self.publication?.reportsForPublication.count
//        if itemsCounter! > 3 {itemsCounter = 3} //we show 3 reports at most
//        let assumedHeight =  itemsCounter! * 44
//        let heightInt = max(assumedHeight, 44)
//        let height = CGFloat(heightInt)
//        return CGSizeMake(size.width, height)
//    }
    
    class func heightForPublication(publication: FCPublication?) -> CGFloat {
        
        if let publication = publication {
            
            let oneOrReportsCount = max(publication.reportsForPublication.count, 1)
            let threeOrReportsCount = min(oneOrReportsCount , 3)
            if threeOrReportsCount != 1 {
                let height = 61 + (threeOrReportsCount-1) * 46
                return CGFloat(height)
            }
        }
        return CGFloat(61)
    }
    
//    func addHeightConstarint (height: CGFloat) {
//          self.heightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1 , constant: height)
//        self.contentView.addConstraint(self.heightConstraint)
//    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.userInteractionEnabled = false
      //  self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = 44
       // self.addHeightConstarint(44)
    }

    
}
