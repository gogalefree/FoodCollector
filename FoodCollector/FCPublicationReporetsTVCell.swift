//
//  FCPublicationReporetsTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/19/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationReporetsTVCell: UITableViewCell {

    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportIcon: UIImageView!

    var report: PublicationReport! {
            didSet{
                if let aReport = self.report {
                    setup(aReport)
                }
        }
    }

    func setup(report: PublicationReport){
        self.reportLabel.text = self.titleForReport(report)
        self.reportDate.text = FCDateFunctions.localizedDateAndTimeStringShortStyle(report.dateOfReport!)
        self.reportIcon.image = self.iconForReport(report)
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
    
    func iconForReport(report: PublicationReport) -> UIImage {
        
        var icon: UIImage
        
        switch FCOnSpotPublicationReportMessage(rawValue: report.report!.integerValue)! {
        case .HasMore:
            icon = FCIconFactory.orangeImage()
            
        default:
            icon = FCIconFactory.redImage()
        }
        return icon
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
