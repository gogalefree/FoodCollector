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
    
    var publication: Publication? {
        didSet {
            guard let publication = publication else {return}
            setup(publication)
        }
    }
    
    func setup(publication: Publication) {
        
        self.imageView.image = defaultImage
        self.shadowView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.1)
        
        if publication.photoBinaryData != nil {animateImage(publication)}
            
        else if !publication.didTryToDownloadImage!.boolValue {
            
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                if image != nil {
                  self.animateImage(publication)
                }
            })
            
        }
    }
    
    func animateImage(publication: Publication) {
        
        let photo = UIImage(data: publication.photoBinaryData!)
        guard let aPhoto = photo else {return}
        self.imageView.image = aPhoto

        dispatch_async(dispatch_get_main_queue()) { () -> Void in

            UIView.animateWithDuration(0.1, animations: { () -> Void in
                
                self.imageView.alpha = 0
                }) { (_) -> Void in
                    self.imageView.image = aPhoto
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.imageView.alpha = 1
                        }, completion: nil)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = defaultImage
    }
}
