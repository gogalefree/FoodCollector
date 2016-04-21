//
//  UserProfilePhotoCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 21/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

protocol UserProfilePhotoCellDelegate: NSObjectProtocol {
    func didRequestPhotoPicker()
}

class UserProfilePhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    weak var delegate: UserProfilePhotoCellDelegate?

    @IBAction func editPhotoAction(sender: AnyObject) {
        presentImagePicker()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if tapGestureRecognizer == nil {
        
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserProfilePhotoCell.presentImagePicker))
            photoImageView.addGestureRecognizer(tapGestureRecognizer)
            photoImageView.userInteractionEnabled = true
            
            photoImageView.layer.cornerRadius = CGRectGetWidth(photoImageView.bounds) / 2
            photoImageView.image = User.sharedInstance.userImage
        }
    }
    
    func presentImagePicker() {
        delegate?.didRequestPhotoPicker()
    }
    
    func animateNewImage(image: UIImage) {
        
        UIView.animateWithDuration(0.1, animations: { 
            self.photoImageView.alpha = 0
            }) { (finished) in
                self.photoImageView.image = image
                UIView.animateWithDuration(0.2, animations: { 
                    self.photoImageView.alpha = 1
                })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
