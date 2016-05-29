//
//  PublicationDetailsDetailsTVCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 4.4.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class PublicationDetailsDetailsTVCell: UITableViewCell {
    
    @IBOutlet weak var shareUserImage: UIImageView!
    @IBOutlet weak var shareLocationLabel: UILabel!
    @IBOutlet weak var shareUserNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    let starImages = [UIImage(named: "Star-No_rating") , UIImage(named: "Star_user_rating")]
    
    var publication: Publication? {
        didSet {
            guard let publication = publication else {return}
            setupUserRating(publication)
        }
    }
    
    func setupUserRating(publication: Publication) {
    
        setDefaultRating()
        if publication.publisherRating != 0 {
            
            starImageView.image = starImages[1]
            ratingLabel.text = String(publication.publisherRating!.floatValue)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        shareUserImage.layer.cornerRadius = CGRectGetWidth(shareUserImage.frame)/2
    }
    
    func setDefaultRating() {
    
        starImageView.image = starImages[0]
        ratingLabel.text = "0.0"
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
