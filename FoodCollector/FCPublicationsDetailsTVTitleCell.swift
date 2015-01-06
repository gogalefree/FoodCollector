//
//  FCPublicationsDetailsTVTitleCellTableViewCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationsDetailsTVTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registeredUsersLabel: UILabel!
    
    var publication: FCPublication? {
        
        didSet {
            
            if let publication = self.publication?{
                self.titleLabel.text = publication.title
                self.subtitleLabel.text = publication.subtitle
                self.addressLabel.text = self.makeDistanceText(publication)
            }
            
        }
    }

    func makeDistanceText(publication: FCPublication) -> String {

        return FCStringFunctions.longDistanceString(publication)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)

        self.subtitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)

        self.addressLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        
        self.titleLabel.numberOfLines = 0
        self.subtitleLabel.numberOfLines = 0
        self.addressLabel.numberOfLines = 0
        
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1.5, constant: 44))
        
        self.registerButton.layer.cornerRadius = self.registerButton.bounds.size.width / 2
        
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
   }
