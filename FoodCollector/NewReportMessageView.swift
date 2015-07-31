//
//  NewReportMessageView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 7/31/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

protocol NewReportMessageViewDelegate: NSObjectProtocol {
    func newReportMessageViewActionDissmiss()
    func newReportMessageViewActionTakeOffAir(publication: FCPublication)
    func newReportMessageViewActionShowDetails(publication: FCPublication)
}

enum NewReportMessageViewState {
    case HasMore , NothingLeft
}

class NewReportMessageView: UIVisualEffectView {

    let actionButtonTitleForHasMoreState = String.localizedStringWithFormat("פרטים", "action button title show details")
    let actionButtonTitleForNothingLeftState = String.localizedStringWithFormat("הסר פרסום", "action button title take off air")

    let titleText = String.localizedStringWithFormat("משתמש נוסף בדרך לאסוף:", "new registration banner title text")
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dissmissButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    
    var delegate: NewReportMessageViewDelegate!
    
    
    var userCreatedPublication: FCPublication! {
        didSet {
            if let publication = userCreatedPublication {
                self.fetchPhotoIfNeeded(publication)
                self.titleLabel.text = publication.title
            }
        }
    }
    
    var state: NewReportMessageViewState! {
        didSet {
            if let state = state {
                self.setUpWithState(state)
            }
        }
    }
    
    func setUpWithState(state: NewReportMessageViewState) {
        
        switch state {
        case .NothingLeft:
            self.actionButton.setTitle(self.actionButtonTitleForNothingLeftState, forState: .Normal)
            self.messageLabel.text = ktookAllTitle

        case .HasMore:
            self.actionButton.setTitle(self.actionButtonTitleForHasMoreState, forState: .Normal)
            self.messageLabel.text = kHasMoreTitle
        }
    }
    
    @IBAction func actionButtonClicked() {
        
        switch self.state! {
            
        case .NothingLeft:
            self.delegate?.newReportMessageViewActionTakeOffAir(self.userCreatedPublication)
            
        case .HasMore:
            self.delegate?.newReportMessageViewActionShowDetails(self.userCreatedPublication)

        }
    }
    
    @IBAction func dissmissButtonClicked() {
    
        self.delegate?.newReportMessageViewActionDissmiss()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = titleText
        var color = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.contentView.backgroundColor = color
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
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            
            self.imageView.alpha = 0
            
            }) { (finished) -> Void in
                
                self.imageView.image = publication.photoData.photo
                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                    
                    self.imageView.alpha = 1
                    
                    }, completion: nil)}
    }
    
    func reset() {
        self.messageLabel.text = ""
        self.imageView.image = UIImage(named: "NoPhotoPlaceholder")
    }
}
