//
//  FCPublicationDetailsDatesCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let publishedTitle = NSLocalizedString("Started:", comment:"a label title meaning: publication start at date and time")

let endsTitle = NSLocalizedString("Ends:", comment:"a label title meaning: will finish on date")

class FCPublicationDetailsDatesCell: UITableViewCell {

    @IBOutlet weak var publishedTitleLabel: UILabel!
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var finishesTitleLabel: UILabel!
    @IBOutlet weak var finishesDateLabel: UILabel!
    
    var publication: FCPublication? {
        didSet{
            
            if let publication = self.publication {
                self.publishedTitleLabel.text = publishedTitle
                self.publishedDateLabel.text = FCDateFunctions.localizedDateAndTimeStringShortStyle(publication.startingDate)
                self.finishesTitleLabel.text = endsTitle
                self.finishesDateLabel.text = FCDateFunctions.localizedDateAndTimeStringShortStyle(publication.endingDate)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.publishedTitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
//        self.publishedDateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
//        self.finishesDateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
//        self.finishesTitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:60 ))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
