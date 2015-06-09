//
//  PublicationDetailsTitleCellTableViewCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationDetailsTitleCellTableViewCell: UITableViewCell {
    
    let cellIdentifier = "PublicationDetailsTitleCellTableViewCell"
    
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let titleColor = UIColor(red: 149/255, green: 149/255, blue: 149/255, alpha: 1)
    
    var publication: FCPublication! {
        didSet {
            if let publication = self.publication {
                self.titleLabel.text = publication.title
            }
        }
    }

    

    override func awakeFromNib() {
        super.awakeFromNib()
        addContentViewConstraints()
        self.userInteractionEnabled = false
        self.titleLabel.textColor = titleColor
    }
    
    func addContentViewConstraints() {
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:45 ))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
