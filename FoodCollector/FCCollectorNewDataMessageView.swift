//
//  FCCollectorNewDataMessageView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/4/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import Foundation

//ConsiderDeprecation

protocol FCNewDataMessageViewDelegate: NSObjectProtocol {
    func showNewPublicationDetails(publication: Publication)
    func dissmissNewPublicationMessageView()
}

class FCCollectorNewDataMessageView: UIVisualEffectView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    let defaultImage = UIImage(named: "NoPhotoPlaceholder")!
    
    weak var delegate: FCNewDataMessageViewDelegate!
    var publication: Publication! {
        didSet{
            if let publication = self.publication {
                self.messageLabel.text = publication.title
                let distanceString = self.makeDistanceText(publication)
                self.titleLabel.text = distanceString
                self.fetchPhotoIfNeeded(publication)
                self.typeLabel.text = kNewEventMessageTitle
            }
        }
    }
    
    @IBAction func showNewPublicationDetailsAction(sender: UIButton) {
        self.delegate.showNewPublicationDetails(self.publication)
    }

    @IBAction func dissmissNewPublicationViewAction(sender: UIButton) {
        self.delegate.dissmissNewPublicationMessageView()
    }

    func makeDistanceText(publication: Publication) -> String {
        
        let addressString = publication.address!
        let distanceString = FCStringFunctions.longDistanceString(publication)
        let displayedString = addressString + "\n" + distanceString
        return displayedString
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
        
        let photo = UIImage(data: publication.photoBinaryData!)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.imageView.alpha = 0
            }) { (finished) -> Void in
                
                self.imageView.image = photo
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.imageView.alpha = 1
                    }, completion: nil)
        }
    
//        self.imageView.animateToAlphaWithSpring(0.2, alpha: 0)
//        self.imageView.image = publication.photoData.photo
//        self.imageView.animateToAlphaWithSpring(0.4, alpha: 1)
    }
    
    private func presentDefaultPhoto()  {
    
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.imageView.alpha = 0
        }) { (finished) -> Void in
            
            self.imageView.image = self.defaultImage
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.imageView.alpha = 1
            }, completion: nil)
        }
    }
    
    
    override func awakeFromNib() {
      
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 1
        //self.titleLabel.textAlignment = .Right
        //self.messageLabel.textAlignment = .Right
    }
}
