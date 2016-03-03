//
//  PublicationDetailsReportCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/9/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let kHasMoreTitle = NSLocalizedString("There’s more to pickup", comment:"The title of a user report which means that there is more food to pickup")
let kTookAllTitle = NSLocalizedString("Took all", comment:"The title of a user report which means that he took all the food")
let kNothingThereTitle = NSLocalizedString("Nothing left", comment:"The title of a user report which means that he found nothing")


class PublicationDetailsReportCell: UITableViewCell {
    
    let identifier = "PublicationDetailsReportCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var indexPath: NSIndexPath!
    var publication: Publication! {
        didSet {
            if self.publication != nil {
                setUp()
            }
        }
    }

    private func setUp() {
        
        guard let reports = publication?.reports else {return}
        
        if reports.count != 0 {

            let reportsArray = FCPublicationsSorter.sortPublicationReportsByDate(publication)
            let report = reportForIndexPath(reportsArray)
            if let aReport = report {
                presentReport(aReport)
            }
            else { presentNoReportsMessage()}
        }
        
        else {
         
            presentNoReportsMessage()
        }
    }
    
    func presentNoReportsMessage() {
        
        self.reportLabel.text = NSLocalizedString("No reports", comment:"the title in the table view cell displayed when a publication has no reports")
        self.timeLabel.text = " "
        self.iconImageView.image = UIImage(named: "Pin-Table-Whole")!
    }
    
    func presentReport(report: PublicationReport){
        self.reportLabel.text = self.titleForReport(report)
        self.timeLabel.text = FCDateFunctions.localizedTimeStringShortStyle(report.dateOfReport!)
        self.iconImageView.image = FCIconFactory.publicationDetailsReportIcon(report)
    }
    
    func titleForReport(report:PublicationReport) -> String {
        
        var title = ""
        
        switch FCOnSpotPublicationReportMessage(rawValue: report.report!.integerValue)! {
            
        case .HasMore:
            title = kHasMoreTitle
        case .TookAll:
            title = kTookAllTitle
        default:
            title = kNothingThereTitle
        }
        
        return title
    }

    
    func reportForIndexPath(reportsArray: [PublicationReport]) -> PublicationReport? {
    
        if let indexPath = self.indexPath {
            
            let reportIndex = indexPath.row
            if reportIndex < reportsArray.count {
                
                return reportsArray[reportIndex]
            }
        }
        
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    class func numberOfReportsToPresent(publication: Publication?) -> Int {
        
        if let publication = publication , reports = publication.reports {
        let num = reports.count
            if num < 3 {
                //if there are no reports - return 1
                //if reports.count > 3 return 3
                //else return reports.count
                return  max(1, num)
            }
        
            return 3
        }
        else {return 1}
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
