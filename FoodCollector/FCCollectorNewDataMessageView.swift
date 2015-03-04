//
//  FCCollectorNewDataMessageView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/4/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

protocol FCNewDataMessageViewDelegate: NSObjectProtocol {
    func showNewPublicationDetails(publication: FCPublication)
    func dissmissNewPublicationMessageView()
}

class FCCollectorNewDataMessageView: UIVisualEffectView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: FCNewDataMessageViewDelegate!
    var publication: FCPublication! {
        didSet{
            if let publication = self.publication {
                self.messageLabel.text = publication.title
                let distanceString = self.makeDistanceText(publication)
                self.titleLabel.text = distanceString
                self.fetchPhotoIfNeeded(publication)
            }
        }
    }
    
    @IBAction func showNewPublicationDetailsAction(sender: UIButton) {
        self.delegate.showNewPublicationDetails(self.publication)
    }

    @IBAction func dissmissNewPublicationViewAction(sender: UIButton) {
        self.delegate.dissmissNewPublicationMessageView()
    }

    func makeDistanceText(publication: FCPublication) -> String {
        
        let addressString = publication.address
        let distanceString = FCStringFunctions.longDistanceString(publication)
        let displayedString = addressString + "\n" + distanceString
        return displayedString
    }
    
    func fetchPhotoIfNeeded(publication: FCPublication) {
        if publication.photoData.photo == nil {
            if !publication.photoData.didTryToDonwloadImage {
                let fetcher = FCPhotoFetcher()
                fetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                    
                    if let photo = image {
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
    
    func presentFetchedPhoto(publication: FCPublication) {
    
        self.imageView.animateToAlphaWithSpring(0.2, alpha: 0)
        self.imageView.image = publication.photoData.photo
        self.imageView.animateToAlphaWithSpring(0.4, alpha: 1)
    }
    
    override func awakeFromNib() {
      
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1
        self.titleLabel.textAlignment = .Right
        self.messageLabel.textAlignment = .Right
    }
}
