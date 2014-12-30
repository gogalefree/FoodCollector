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
        configureDistanceLabel(publication)
        iconForPublication(publication)
        downloadImage()
    }
    
    func configureDistanceLabel(publication: FCPublication) {
        let distanceText = String.localizedStringWithFormat("km away", "describes the number of km from the user's location")
        let distanceNumbers = FCStringFunctions.formmatedDistanceString(publication.distanceFromUserLocation)
        self.distanceLabel.text = NSString(format: "%@ %@", distanceText, distanceNumbers)
    }
    
    func downloadImage() {
        if self.publication?.photoData.photo != nil {showImage()}
            
        else if (publication?.photoData.didTryToDonwloadImage == false) {
            
            let photoFetcher = FCPhotoFetcher()
            photoFetcher.fetchPhotoForPublication(self.publication!, completion: { (image) -> Void in
                
                if let photo = image {
                    
                    self.publication?.photoData.photo = photo
                    self.publication?.photoData.didTryToDonwloadImage = true
                    self.showImage()
                }
            })
        }
            
        else {
            
            let localFilePath = FCModel.sharedInstance.photosDirectoryUrl.URLByAppendingPathComponent("/\(self.publication?.photoUrl)")
            let image = UIImage(contentsOfFile: localFilePath.path!)
            if let photo = image {
                self.publication?.photoData.photo = image
                showImage()
            }
        }
    }
    
    func showImage() {
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.photoImageView.alpha = 0
            self.photoImageView.image = self.publication?.photoData.photo
            self.photoImageView.alpha = 1
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
    
    func iconForPublication(publication: FCPublication){
        
        switch publication.countOfRegisteredUsers {
            
        case 0...1:
            greenImage(publication.typeOfCollecting)
            
        case 2...4:
            orangeImage(publication.typeOfCollecting)
            
        default:
            redImage(publication.typeOfCollecting)
        }
    }
    
    func greenImage(typeOfCollecting: FCTypeOfCollecting) {
        
        switch typeOfCollecting {
            
        case .ContactPublisher:
            self.iconImageView.image = UIImage(named: "PinGreenCall")
        default:
            self.iconImageView.image = UIImage(named: "PinGreen")
        }
    }
    
    func orangeImage(typeOfCollecting: FCTypeOfCollecting) {
        
        switch typeOfCollecting {
            
        case .ContactPublisher:
            self.iconImageView.image = UIImage(named: "PinYellowCall")
        default:
            self.iconImageView.image = UIImage(named: "PinYellow")
        }
    }
    
    func redImage(typeOfCollecting: FCTypeOfCollecting) {
        
        switch typeOfCollecting {
            
        case .ContactPublisher:
            self.iconImageView.image = UIImage(named: "PinRedCall")
        default:
            self.iconImageView.image = UIImage(named: "PinRed")
        }
    }
}
