//
//  FCPublicationSingleReportCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/5/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let kHasMoreTitle = String.localizedStringWithFormat("משתמש דיווח: נשאר עוד","the title of a user report which means that there is more food to pick up")

let ktookAllTitle = String.localizedStringWithFormat("משתמש דיווח: לקחתי הכל","the title of a user report which means that he took all the food")

let kNothingThereTitle = String.localizedStringWithFormat("משתמש דיווח: לא מצאתי כלום","the title of a user report which means that he found nothing")

class FCPublicationSingleReportCell: UITableViewCell {
    
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportIcon: UIImageView!
    
    var typeOfCollecting: FCTypeOfCollecting = FCTypeOfCollecting.FreePickUp
    var report: FCOnSpotPublicationReport? {
        didSet{
            if let aReport = self.report {
                setup(aReport)
            }
        }
    }
    
    func setup(report: FCOnSpotPublicationReport){
        
        self.reportLabel.text = self.titleForReport(report)
        self.reportDate.text = FCDateFunctions.localizedDateAndTimeStringShortStyle(report.date)
        self.reportIcon.image = self.iconForReport(report)
    }
    
    func noReports() {
        self.reportLabel.text = String.localizedStringWithFormat("No reports", "the title in the table view cell displayed when a publication has no reports")
        self.reportDate.text = ""
        self.reportIcon.image = FCIconFactory.greenImage(FCTypeOfCollecting.FreePickUp)
//        self.layoutIfNeeded()
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
                icon = FCIconFactory.orangeImage(self.typeOfCollecting)
                
            default:
                icon = FCIconFactory.redImage(self.typeOfCollecting)
            }
        return icon
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reportLabel.text = ""
        self.reportDate.text = ""
        self.reportIcon.image = FCIconFactory.greenImage(FCTypeOfCollecting.FreePickUp)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 52))
            self.noReports()
        }
    
//    override func sizeThatFits(size: CGSize) -> CGSize {
//        return CGSizeMake(size.width, 44)
//    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
