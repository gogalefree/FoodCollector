//
//  PublicationDetailsImageCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

protocol PublicationDetailsImageCellDelegate: NSObjectProtocol {
    func didRequestFullScreenImage()
}

class PublicationDetailsImageCell: UITableViewCell {
    
    let cellIdentifier = "PublicationDetailsImageCell"
    
    @IBOutlet weak var publicationImageView: UIImageView!
    @IBOutlet weak var registeredUsersIconImageView: UIImageView!
    @IBOutlet weak var registeredUsersCounterlabel: UILabel!
    @IBOutlet weak var registeredUsersTitlelabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    let registeredUserGreenImage = UIImage(named: "UserGreen")
    let registeredUserGreenTextColor = UIColor(red: 38/255, green: 166/255, blue: 91/255, alpha: 1)
    let unregisteredUserBlueTextColor = kNavBarBlueColor
    let unRegisteredUserBlueImage = UIImage(named: "User")
    
    weak var delegate: PublicationDetailsImageCellDelegate!

    var publication: FCPublication! {
        didSet {
            if self.publication != nil {
                setUp()
            }
        }
    }


    private func setUp() {
        self.addressLabel.text = makeAddressText(self.publication)
        reloadPublicationImage()
        reloadRegisteredUserIconCounter()
    }
    
    final func reloadPublicationImage() {
    
        if let photo = publication.photoData.photo {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.publicationImageView.alpha = 0
            }, completion: { (finished) -> Void in
                self.publicationImageView.image = photo
                self.publicationImageView.animateToAlphaWithSpring(0.4, alpha: 1)
            })
        }
    }
    
    final func reloadRegisteredUserIconCounter() {
    
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            self.registeredUsersCounterlabel.alpha = 0
            self.registeredUsersIconImageView.alpha = 0
            
        }) { (finished) -> Void in
            // TODO: Add support for localized number format (for non european language)
            
            self.registeredUsersCounterlabel.text = "\(self.publication.registrationsForPublication.count)"
            self.defineImageColorForUser()
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                
                self.registeredUsersCounterlabel.alpha = 1
                self.registeredUsersIconImageView.alpha = 1

                
            }, completion: nil)}
    }
    
    private func defineImageColorForUser() {
        
        switch self.publication.didRegisterForCurrentPublication {
        
        case true:
            self.registeredUsersIconImageView.image = self.registeredUserGreenImage
            self.registeredUsersCounterlabel.textColor = self.registeredUserGreenTextColor
        
        case false:
            self.registeredUsersIconImageView.image = self.unRegisteredUserBlueImage
            self.registeredUsersCounterlabel.textColor = self.unregisteredUserBlueTextColor
        }
    }
    
    private func makeAddressText(publication: FCPublication) -> String {
        
        let addressString = publication.address
        let distanceString = FCStringFunctions.longDistanceString(publication)
        let displayedString = addressString + "\n" + distanceString
        return displayedString
    }

    final override func awakeFromNib() {
        super.awakeFromNib()
        self.publicationImageView.layer.cornerRadius = CGRectGetWidth(self.publicationImageView.frame) / 2
    }

    final override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //super.touchesBegan(touches, withEvent: event)
        let touch = touches.first
        if let touch = touch {
            
            let touchLocation =  touch.locationInView(self.contentView)
            if CGRectContainsPoint(self.publicationImageView.frame, touchLocation) {
            
                if let delegate = self.delegate {
                    delegate.didRequestFullScreenImage()
                }
            }
        }
    }
}
