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
    var publication: FCPublication? {
        didSet{
            if let publication = self.publication? {
                self.setup(publication)
            }
        }
    }
    
    func setup(publication: FCPublication) {
        
        if publication.reportsForPublication.count != 0 {
                self.noReports = false
                return
        }
        
        self.noReports = true
    }
 
    
    //MARK: - tableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = self.publication?.reportsForPublication.count
        return  max(1, num!)
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
    
    override func sizeThatFits(size: CGSize) -> CGSize {
    
        if self.noReports {
            let cellSize = CGSizeMake(size.width, 54)
            return cellSize
        }
        
        var itemsCounter = self.publication?.reportsForPublication.count
        var assumedHeight =  itemsCounter! * 44 + 10
        var height = CGFloat(assumedHeight)
        return CGSizeMake(size.width, height)
    }

    //MARK: - cell strings
    
    func makeReportTitle (report: FCOnSpotPublicationReport) -> String {
        var title = "user reportes title"
        return title
    }
    
    func makeReportSubTitle (report: FCOnSpotPublicationReport) -> String {
        var subtitle = "here come the date"
        return subtitle
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

        override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
