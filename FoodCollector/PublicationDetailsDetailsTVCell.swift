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
    
    let yellowBackgroundView = UIView()
    
    let starImages = [UIImage(named: "Star-No_rating") , UIImage(named: "Star_user_rating"), UIImage(named: "Star-rating")]
    
    var publication: Publication? {
        didSet {
            guard let publication = publication else {return}
            setupUserRating(publication)
        }
    }
    
    func setupUserRating(publication: Publication) {
    
        setDefaultRating()
        
        if publication.publisherRating != 0 {
            
            self.starImageView.image = starImages[2]
            self.starImageView.backgroundColor = UIColor.clearColor()
            self.starImageView.clipsToBounds = true
            let backgroundFraction: CGFloat = CGFloat((publication.publisherRating!.doubleValue / 5))
            yellowBackgroundView.frame = self.starImageView.frame
            yellowBackgroundView.frame.size.width = yellowBackgroundView.frame.size.width * backgroundFraction * 0.9
            yellowBackgroundView.backgroundColor = UIColor.yellowColor()
            
            self.contentView.addSubview(yellowBackgroundView)
            self.contentView.sendSubviewToBack(yellowBackgroundView)
            ratingLabel.text = String(publication.publisherRating!.floatValue)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.yellowBackgroundView.removeFromSuperview()
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
