//
//  FCPublicationsTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 12/30/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationsTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeRemains: UILabel!
    @IBOutlet weak var countOfRegisteredUsersLabel: UILabel!
    @IBOutlet weak var audianceIconImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    let defaultImage = UIImage(named: "NoPhotoPlaceholder")
    
    var publication: Publication? {
        
        didSet{
            if let thePublication = self.publication {
                setUp(thePublication)
            }
        }
    }
    
    
    
    func setUp(publication: Publication) {
        self.titleLabel.text = publication.title
        self.addressLabel.text = publication.address
        self.distanceLabel.text = FCStringFunctions.shortDistanceString(publication)
        self.audianceIconImageView.image = FCIconFactory.typeOfPublicationIcon(publication)
        self.countOfRegisteredUsersLabel.text = String.localizedStringWithFormat(NSLocalizedString("%@ users joined", comment: "Number of users registered for a sharing. the first place holder is a number. e.g: '55 users joined'"), publication.countOfRegisteredUsersAsString)
        self.timeRemains.text = FCDateFunctions.timeStringDaysAndHoursRemain(fromDate: publication.endingData!, toDate: NSDate())
        
        downloadImage()
    }
    
    func downloadImage() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in

            if self.publication?.photoBinaryData != nil {self.showImage()}
            else if (self.publication?.didTryToDownloadImage == false) {
                
                let photoFetcher = FCPhotoFetcher()
                photoFetcher.fetchPhotoForPublication(self.publication!, completion: { (image) -> Void in
                    
                    if image != nil {
                        self.showImage()
                    }
                })
            }
        })
    }
    
    func showImage() {
        
        let photo = UIImage(data: (self.publication?.photoBinaryData)!)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.photoImageView.alpha = 0
                self.photoImageView.image = photo
                self.photoImageView.alpha = 1
            })

        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoImageView.image = defaultImage
//        if let publication = self.publication {
//            
//  //          if publication.photoBinaryData != nil {animateImage(publication)}
//        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = UIImage(named: "NoPhotoPlaceholder")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:96 ))
        self.photoImageView.layer.cornerRadius = CGRectGetWidth(self.photoImageView.bounds) / 2
        

    }
    
}

