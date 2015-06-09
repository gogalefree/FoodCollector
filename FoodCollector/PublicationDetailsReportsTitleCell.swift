//
//  PublicationDetailsReportsTitleCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationDetailsReportsTitleCell: UITableViewCell {
    
    let cellIdentifier = "PublicationDetailsReportsTitleCell"
    let reportsTitle = String.localizedStringWithFormat("דיווחי משתמשים", "publication details reports title")
    
    @IBOutlet weak var reportsTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.reportsTitleLabel.text = reportsTitle
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
