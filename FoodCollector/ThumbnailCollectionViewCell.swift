//
//  ThumbnailCollectionViewCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

let thumbnailCollectionViewCellID = "thumbnailCollectionViewCellID"

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imageView : UIImageView!

    let defaultImage = UIImage(named: "NoPhotoPlaceholder")
    
    var publication: FCPublication? {
        didSet {
            guard let publication = publication else {return}
            setup(publication)
        }
    }
    
    func setup(publication:FCPublication) {
        
        self.imageView.image = defaultImage
        self.shadowView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.1)
        if publication.photoData.photo != nil {animateImage(publication)}
        else if !publication.photoData.didTryToDonwloadImage {
            
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                if image != nil {
                  self.animateImage(publication)
                }
            })
            
        }
    }
    
    func animateImage(publication: FCPublication) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.imageView.alpha = 0
            }) { (_) -> Void in
                self.imageView.image = publication.photoData.photo!
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.imageView.alpha = 1
                    }, completion: nil)
        }
    }
}
