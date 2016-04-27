//
//  FCPublicationReporetsTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/19/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationReporetsTVCell: UITableViewCell {

    let userReportedString =
        NSLocalizedString("User Reported", comment: "a title before a user report")
    let defaultImage = UIImage(named: "ProfilePic")
    
    @IBOutlet weak var reporterNameLabel: UILabel!
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
        var reporterName = report.reoprterUserName?.capitalizedString ?? ""
        reporterName =  reporterName == "" ? userReportedString : reporterName
        self.reporterNameLabel.text = reporterName + ":"
        self.reportLabel.text = self.titleForReport(report)
        self.reportDate.text = FCDateFunctions.localizedDateAndTimeStringShortStyle(report.dateOfReport!)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reportIcon.layer.cornerRadius = CGRectGetWidth(reportIcon.bounds) / 2
        downloadReporterImage()
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
    
    func downloadReporterImage() {
        
        self.reportIcon.image = defaultImage
        
        if let imageData = report.reporterImageData {
            
            let image = UIImage(data: imageData)
            self.reportIcon.image = image
        }
        
        else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                let fetcher = FCUserPhotoFetcher()
                fetcher.userPhotoForReport(self.report) { (image) in
                    if image != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.reportIcon.image = image
                        }
                    }
                }
            }
        }
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
