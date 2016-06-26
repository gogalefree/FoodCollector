//
//  ThumbnailCollectionViewCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

let thumbnailCollectionViewCellID = "thumbnailCollectionViewCellI"

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imageView : UIImageView!

    let defaultImage = UIImage(named:"Nophoto")
   
    var publication: Publication? {
        didSet {
            guard let publication = publication else {return}
            setup(publication)
        }
    }
    
    func setup(publication: Publication) {
        
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = defaultImage
        self.shadowView.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.1)
        
        print(publication.title)
        print((publication.didTryToDownloadImage))
        print(publication.photoBinaryData?.length)
        
        if publication.photoBinaryData != nil {animateImage(publication)}
            
        else  {
            
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                if image != nil {
                  self.animateImage(publication)
                }
            })
            
        }
    }
    
    func animateImage(publication: Publication) {
        
        self.imageView.contentMode = .ScaleAspectFill
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.image = defaultImage
        if let publication = self.publication {
            
            if publication.photoBinaryData != nil {
                let photo = UIImage(data: publication.photoBinaryData!)
                self.imageView.image = photo
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = defaultImage
    }
}
