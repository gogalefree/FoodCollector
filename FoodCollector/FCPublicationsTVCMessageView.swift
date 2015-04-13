//
//  FCPublicationsTVCMessageView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/6/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

let kNewPublicationMessage = String.localizedStringWithFormat("אירוע חדש בקירבתך", "title of the message banner meaning that there is nothing left at thepublication spot")

enum FCPublicationTVCMessageViewState {
    case DeleteMessage
    case NewPublicationMessage
}

class FCPublicationsTVCMessageView: UIVisualEffectView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    var state: FCPublicationTVCMessageViewState = FCPublicationTVCMessageViewState.DeleteMessage {
        didSet {
            switch self.state {
           
            case .DeleteMessage:
                self.titleLabel.text = kpublicationDeletedAlertMessage
                var color = UIColor.redColor().colorWithAlphaComponent(0.1)
                self.contentView.backgroundColor = color
            
            case .NewPublicationMessage:
                self.titleLabel.text = kNewPublicationMessage
                var color = UIColor.greenColor().colorWithAlphaComponent(0.1)
                self.contentView.backgroundColor = color
            }
        }
    }

    var publication: FCPublication! {

        didSet {
            self.contentLabel.text = publication.title
            self.fetchPhotoIfNeeded(publication)
            self.contentLabel.sizeToFit()
            var height = CGRectGetMaxY(self.contentLabel.frame) + 8
            height = max(height, 66)
            self.frame.size.height = height
        }
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
    
    func reset() {
        self.titleLabel.text = ""
        self.contentLabel.text = ""
        self.imageView.image = UIImage(named: "NoPhoto-Placeholder")
    }
    
   
}
