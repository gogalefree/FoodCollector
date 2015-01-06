//
//  FCPublicationDetailsPhotoCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/6/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let noPhotoTitle = String.localizedStringWithFormat("No Image", "a label title that indicates that a publication has no image")

let kPublicationPhotoCellHeightNoImage: CGFloat = 44.0
let kPublicationPhotoCellHeightHasImage: CGFloat = 300.0


class FCPublicationDetailsPhotoCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
//    @IBOutlet weak var noPhotoLabel: UILabel!
    
    var heightConstraints = [NSLayoutConstraint]()
    
    var publication: FCPublication? {
        didSet{
            
            if let publication = self.publication{
               
                if let photo = publication.photoData.photo {
                    
                    //has image
                    self.photoImageView.image = photo
                    self.updateHeight(kPublicationPhotoCellHeightHasImage)
                    self.photoImageView.alpha = 1
                    //self.noPhotoLabel.alpha = 0
                    
                    
        
                }
                else {
                    self.updateHeight(kPublicationPhotoCellHeightNoImage)
                    self.photoImageView.alpha = 0
                    self.photoImageView.image = nil
                    //self.noPhotoLabel.alpha = 1
                }
            }
        }
    }

    func updateHeight(height: CGFloat){
        
        let heightConstraint = self.heightConstraints.last!
        heightConstraint.constant = height
        self.updateConstraintsIfNeeded()
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.userInteractionEnabled = false
        
        self.heightConstraints.append(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: kPublicationPhotoCellHeightNoImage))
        
        self.contentView.addConstraints(self.heightConstraints)
    }

  
}
