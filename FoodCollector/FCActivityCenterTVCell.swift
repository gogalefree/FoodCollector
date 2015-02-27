//
//  FCActivityCenterTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCActivityCenterTVCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var publication: FCPublication! {
        didSet{
            if let publication = self.publication {
                self.titleLabel.text = publication.title
                self.fetchPhotoIfNeeded()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.textColor = UIColor.whiteColor()
        
         self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:55 ))
        
    }

    func fetchPhotoIfNeeded() {
    
        self.iconImageView.alpha = 0
        if self.publication.photoData.photo != nil {
            self.iconImageView.image = self.publication.photoData.photo
        }
        else if !self.publication.photoData.didTryToDonwloadImage {
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(self.publication, completion: { (image) -> Void in
                self.iconImageView.image = self.publication.photoData.photo
            })
        }
        self.iconImageView.animateToAlphaWithSpring(0.4, alpha: 1)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.iconImageView.image = nil
        self.userInteractionEnabled = false

    }

}
