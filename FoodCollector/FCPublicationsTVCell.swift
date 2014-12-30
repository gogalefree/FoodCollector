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
        self.photoImageView.image = nil //change to default image
        self.titleLabel.text = publication.title
        self.distanceLabel.text = FCStringFunctions.formmatedDistanceString(publication.distanceFromUserLocation)
        downloadImage()
    }
    
    func downloadImage() {
        if self.publication?.photoData.photo != nil {showImage()}
        else if (publication?.photoData.didTryToDonwloadImage == false) {
            
            println("download image for publication: \(self.publication?.photoUrl)")
            
            
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
        self.translatesAutoresizingMaskIntoConstraints()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
