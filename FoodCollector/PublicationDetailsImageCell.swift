//
//  PublicationDetailsImageCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationDetailsImageCell: UITableViewCell {
    
    let cellIdentifier = "PublicationDetailsImageCell"
    
    @IBOutlet weak var publicationImageView: UIImageView!
    @IBOutlet weak var registeredUsersIconImageView: UIImageView!
    @IBOutlet weak var registeredUsersCounterlabel: UILabel!
    @IBOutlet weak var registeredUsersTitlelabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!


    var publication: FCPublication! {
        didSet {
            if let publication = self.publication {
                setUp()
            }
        }
    }


    func setUp() {
        self.addressLabel.text = makeAddressText(self.publication)
        reloadPublicationImage()
        self.registeredUsersCounterlabel.text = "\(publication.countOfRegisteredUsers)"
    }
    
    func reloadPublicationImage() {
    
        if let photo = publication.photoData.photo {
            self.publicationImageView.animateToAlphaWithSpring(0.2, alpha: 0)
            self.publicationImageView.image = photo
            self.publicationImageView.animateToAlphaWithSpring(0.2, alpha: 1)
        }
    }
    
    func makeAddressText(publication: FCPublication) -> String {
        
        let addressString = publication.address
        let distanceString = FCStringFunctions.longDistanceString(publication)
        let displayedString = addressString + "\n" + distanceString
        return displayedString
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.publicationImageView.layer.cornerRadius = CGRectGetWidth(self.publicationImageView.frame) / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
