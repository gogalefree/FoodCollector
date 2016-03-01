//
//  FetchedDataNotificationView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

protocol FetchedDataNotificationViewDelegate: NSObjectProtocol {
    func presentPublicationFromNotificationView(notificationView: FetchedDataNotificationView)
    func dissmissNotificationView(notificationView: FetchedDataNotificationView)
}

class FetchedDataNotificationView: UIVisualEffectView {

  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dissmissButton: UIButton!
    @IBOutlet weak var presentButton: UIButton!
    
    weak var delegate: FetchedDataNotificationViewDelegate?
    var visibleOrigin = CGPointMake(0, -300)
    
    var notification: FetchedDataNotification? {
        
        didSet {
            guard let notification = notification else{return}
            setup(notification)
        }
    }
    
    func setup(notification: FetchedDataNotification) {
    
        self.titleLabel.text =  notification.title
        self.messageLabel.text = notification.publication.title
       // var color = UIColor.greenColor().colorWithAlphaComponent(0.1)
       // if notification.type == .DeletePublication {color = UIColor.redColor().colorWithAlphaComponent(0.1)}
       // self.contentView.backgroundColor = color

        
        if notification.publication.photoBinaryData != nil {
            presentPhoto()
        }
        
        else {
            let photoFetcher = FCPhotoFetcher()
            photoFetcher.fetchPhotoForPublication(notification.publication, completion: { (image) -> Void in
                self.presentPhoto()
            })
        }
    }
    
    func presentPhoto() {
        
        self.imageView.image = UIImage(data: notification!.publication.photoBinaryData!)
    }
    
    @IBAction func presentPublicationAction() {
        
        delegate?.presentPublicationFromNotificationView(self)
    }
    
    @IBAction func dissmissAction() {
        
        delegate?.dissmissNotificationView(self)
    }
}
