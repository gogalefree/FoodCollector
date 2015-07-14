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
    @IBOutlet weak var notificationLabel: UILabel!
    
    final let placeholderImage = UIImage(named: "PlaceholderActivity")

    
    final var publication: FCPublication! {
        
        didSet{
        
            if let publication = self.publication {
                self.titleLabel.text = publication.title
                self.fetchPhotoIfNeeded()
                showNotificationNumber()
            }
        }
    }
    
    final override func awakeFromNib() {

        super.awakeFromNib()
        self.titleLabel.textColor = UIColor.whiteColor()
        self.iconImageView.layer.cornerRadius = CGRectGetWidth(self.iconImageView.frame)/2
        self.notificationLabel.layer.cornerRadius = CGRectGetWidth(self.notificationLabel.frame) / 2
        self.notificationLabel.backgroundColor = UIColor.lightGrayColor()
        self.notificationLabel.textColor = UIColor.darkGrayColor()
        
    }

    final func fetchPhotoIfNeeded() {
    
        if self.publication.photoData.photo != nil {
            self.iconImageView.image = self.publication.photoData.photo
        }
        
        else if !self.publication.photoData.didTryToDonwloadImage {
            
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(self.publication, completion: { (image) -> Void in
                self.publication.photoData.didTryToDonwloadImage = true
                self.iconImageView.image = image
            })
        }
    }
    
    
    final override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.iconImageView.image = placeholderImage
        self.userInteractionEnabled = true
    }
    
    final func hideNotificationNumber() {
        self.notificationLabel.alpha = 0
    }
    
    final func showNotificationNumber(){
        
        if publication.countOfRegisteredUsers > 0 {
            self.notificationLabel.alpha = 1
            self.notificationLabel.text = toString()
        }
            
        else{
            hideNotificationNumber()
        }
    }
    
    final private func toString() -> String {
        return "\(publication.countOfRegisteredUsers)"
    }

}
