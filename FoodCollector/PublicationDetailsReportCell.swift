//
//  PublicationDetailsReportCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/9/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let kHasMoreTitle = String.localizedStringWithFormat("User reported: More left to pickup","the title of a user report which means that there is more food to pickup")
let ktookAllTitle = String.localizedStringWithFormat("User reported: Picked up everything","the title of a user report which means that he took all the food")
let kNothingThereTitle = String.localizedStringWithFormat("User reported: Nothing left","the title of a user report which means that he found nothing")


class PublicationDetailsReportCell: UITableViewCell {
    
    let identifier = "PublicationDetailsReportCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var indexPath: NSIndexPath!
    var publication: FCPublication! {
        didSet {
            if self.publication != nil {
                setUp()
            }
        }
    }

    private func setUp() {
                
        if publication.reportsForPublication.count != 0 {

            FCPublicationsSorter.sortPublicationReportsByDate(publication)
            let report = reportForIndexPath()
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
        
        self.reportLabel.text = String.localizedStringWithFormat("No reports", "the title in the table view cell displayed when a publication has no reports")
        self.timeLabel.text = " "
        self.iconImageView.image = UIImage(named: "Pin-Table-Whole")!
    }
    
    func presentReport(report: FCOnSpotPublicationReport){
        
        self.reportLabel.text = self.titleForReport(report)
        self.timeLabel.text = FCDateFunctions.timeStringEuroStyle(report.date)
        self.iconImageView.image = FCIconFactory.publicationDetailsReportIcon(report)
    }
    
    func titleForReport(report:FCOnSpotPublicationReport) -> String {
        
        var title = ""
        
        switch report.onSpotPublicationReportMessage {
            
        case .HasMore:
            title = kHasMoreTitle
        case .TookAll:
            title = ktookAllTitle
        default:
            title = kNothingThereTitle
        }
        
        return title
    }

    
    func reportForIndexPath() -> FCOnSpotPublicationReport? {
    
        if let indexPath = self.indexPath {
            
            let reportIndex = indexPath.row
            return self.publication.reportsForPublication[reportIndex]
        }
        
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    class func numberOfReportsToPresent(publication: FCPublication?) -> Int {
        
        if let publication = publication {
        let num = publication.reportsForPublication.count
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
