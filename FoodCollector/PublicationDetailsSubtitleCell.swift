//
//  PublicationDetailsSubtitleCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationDetailsSubtitleCell: UITableViewCell {
    
    let cellIdentifier = "PublicationDetailsSubtitleCell"
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var publication: Publication! {
        didSet {
            if let publication = self.publication {
                subtitleLabel.text = publication.subtitle
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.addContentViewConstraints()
    }
    
    func addContentViewConstraints() {
        
         self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:85 ))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
