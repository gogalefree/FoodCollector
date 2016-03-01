//
//  NewRegistrationBannerView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 7/5/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class NewRegistrationBannerView: UIVisualEffectView {
    
    let titleText = NSLocalizedString("Another user is en route to pickup:", comment:"new registration banner title text")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var userCreatedPublication: Publication! {
        didSet {
            if let publication = userCreatedPublication {
                self.messageLabel.text = publication.title
                self.fetchPhotoIfNeeded(publication)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = titleText
        let color = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.contentView.backgroundColor = color
    }
    
    func fetchPhotoIfNeeded(publication: Publication) {
        if publication.photoBinaryData == nil {
            if !publication.didTryToDownloadImage!.boolValue {
                let fetcher = FCPhotoFetcher()
                fetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                    
                    if image != nil {
                        //present photo
                        self.presentFetchedPhoto(publication)
                    }
                })
            }
        }
        else {
            //presentThePhoto
            self.presentFetchedPhoto(publication)
        }
    }
    
    func presentFetchedPhoto(publication: Publication) {
        
        let image = UIImage(data: publication.photoBinaryData!)
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            self.imageView.alpha = 0
            
        }) { (finished) -> Void in
                
                self.imageView.image = image
                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    
                  self.imageView.alpha = 1
        
                }, completion: nil)}
    }
    
    func reset() {
        self.messageLabel.text = ""
        self.imageView.image = UIImage(named: "NoPhotoPlaceholder")
    }
}
