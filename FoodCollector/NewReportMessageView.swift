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
    case HasMore , NothingLeft , RegisteredUser
}

class NewReportMessageView: UIVisualEffectView {

    let actionButtonTitleForHasMoreState = String.localizedStringWithFormat("פרטים", "action button title show details")
    let actionButtonTitleForNothingLeftState = String.localizedStringWithFormat("הסר פרסום", "action button title take off air")

    let titleText = String.localizedStringWithFormat("משתמש נוסף בדרך לאסוף:", "new registration banner title text")
    
    var panStartPoin: CGPoint!
    
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
            
        case .RegisteredUser:
            self.actionButton.alpha = 0
            let (_ , report ) = FCUserNotificationHandler.sharedInstance.recivedReports.last!
            self.messageLabel.text = self.messageForReport(report)
        }
    }
    
    func messageForReport(report: FCOnSpotPublicationReport) -> String {
        switch report.onSpotPublicationReportMessage {
        case  .HasMore :
            return kHasMoreTitle
            
        case .TookAll:
            return ktookAllTitle
            
        case .NothingThere:
            return kNothingThereTitle
        }
    }
    
    @IBAction func actionButtonClicked() {
        
        switch self.state! {
            
        case .NothingLeft:
            self.delegate?.newReportMessageViewActionTakeOffAir(self.userCreatedPublication)
            
        case .HasMore:
            self.delegate?.newReportMessageViewActionShowDetails(self.userCreatedPublication)
            
        default:
            break

        }
    }
    
    @IBAction func dissmissButtonClicked() {
    
        self.delegate?.newReportMessageViewActionDissmiss()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.text = titleText
        let color = UIColor.greenColor().colorWithAlphaComponent(0.1)
        self.contentView.backgroundColor = color
        self.addGestures()
    }
    
    func addGestures() {
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panInView:")
        self.addGestureRecognizer(panRecognizer)
    }
    
    func panInView(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
           panStartPoin = recognizer.velocityInView(recognizer.view!)
        case .Changed:
            let point = recognizer.velocityInView(recognizer.view)
            if point.y < panStartPoin.y {
                self.dissmissButtonClicked()
            }
        default:
            break
        }
    }
    
    func fetchPhotoIfNeeded(publication: FCPublication) {
        if publication.photoData.photo == nil {
            if !publication.photoData.didTryToDonwloadImage {
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
    
    func presentFetchedPhoto(publication: FCPublication) {
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            self.imageView.alpha = 0
            
            }) { (finished) -> Void in
                
                self.imageView.image = publication.photoData.photo
                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    
                    self.imageView.alpha = 1
                    
                    }, completion: nil)}
    }
    
    func reset() {
        self.actionButton.alpha = 1
        self.messageLabel.text = ""
        self.imageView.image = UIImage(named: "NoPhotoPlaceholder")
    }
}
