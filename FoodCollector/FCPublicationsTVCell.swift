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
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var publication: FCPublication? {
        
        didSet{
            if let thePublication = self.publication {
                setUp(thePublication)
            }
        }
    }
    
    func setUp(publication: FCPublication) {
        self.photoImageView.image = UIImage(named: "upp90.jpg") //change to default image
        self.titleLabel.text = publication.title
        self.distanceLabel.text = FCStringFunctions.longDistanceString(publication)
        self.iconImageView.image = FCIconFactory.smallIconForPublication(publication)
        downloadImage()
    }
    
        
    func downloadImage() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            if self.publication?.photoData.photo != nil {self.showImage()}
                
            else if (self.publication?.photoData.didTryToDonwloadImage == false) {
                
                self.publication?.photoData.didTryToDonwloadImage = true
                let photoFetcher = FCPhotoFetcher()
                photoFetcher.fetchPhotoForPublication(self.publication!, completion: { (image) -> Void in
                    
                    if let photo = image {
                        
                        self.publication?.photoData.photo = photo
                        self.showImage()
                    }
                })
            }
        })
        
//        else {
//            
//            self.publication?.photoData.didTryToDonwloadImage = true
//            let localFilePath = FCModel.sharedInstance.photosDirectoryUrl.URLByAppendingPathComponent("/\(self.publication?.photoUrl)")
//            let image = UIImage(contentsOfFile: localFilePath.path!)
//            if let photo = image {
//                self.publication?.photoData.photo = image
//                showImage()
//            }
//        }
    }
    
    func showImage() {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in

            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.photoImageView.alpha = 0
                self.photoImageView.image = self.publication?.photoData.photo
                self.photoImageView.alpha = 1
            })

        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
 //       self.translatesAutoresizingMaskIntoConstraints()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension FCPublicationsTVCell {
 
    // MARK: - Cell Icon Picker
    
   }
