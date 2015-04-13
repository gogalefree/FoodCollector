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

    var report: FCOnSpotPublicationReport! {
            didSet{
                if let aReport = self.report {
                    setup(aReport)
                }
        }
    }

    func setup(report: FCOnSpotPublicationReport){
        let text =  self.titleForReport(report)
        self.reportLabel.text = self.titleForReport(report)
        self.reportDate.text = FCDateFunctions.localizedDateAndTimeStringShortStyle(report.date)
        self.reportIcon.image = self.iconForReport(report)
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
    
    func iconForReport(report: FCOnSpotPublicationReport) -> UIImage {
        
        var icon: UIImage
        
        switch report.onSpotPublicationReportMessage{
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
