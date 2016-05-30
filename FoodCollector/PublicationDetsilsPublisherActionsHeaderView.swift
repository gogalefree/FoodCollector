//
//  PublicationDetsilsPublisherActionsHeaderView.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import Foundation

protocol PublicationDetsilsPublisherActionsHeaderDelegate: NSObjectProtocol {
    

    func didRequestPostToFacebookForPublication()
    func didRequestPostToTwitterForPublication()
    func publisherDidRequestSmsCollectors()
    func publisherDidRequestPhoneCall()
}

class PublicationDetsilsPublisherActionsHeaderView: UIView {
    
    let buttonPressColor = kNavBarBlueColor //UIColor(red: 32/255, green: 137/255, blue: 75/255, alpha: 1)
    let normalColor = UIColor.clearColor()
    
    @IBOutlet weak var button1to2widthConstraint : NSLayoutConstraint!
    @IBOutlet weak var button2to3widthConstraint : NSLayoutConstraint!
    @IBOutlet weak var button3to4widthConstraint : NSLayoutConstraint!


    
    @IBOutlet weak var facebookButton:  UIButton!
    @IBOutlet weak var twitterButton:   UIButton!
    @IBOutlet weak var smsButton:       UIButton!
    @IBOutlet weak var phoneCallButton: UIButton!
    
    weak var delegate: PublicationDetsilsPublisherActionsHeaderDelegate!
    
    var buttons = [UIButton]()
    
    var publication: Publication! {
        didSet {
            if let publication = self.publication {
                configureInitialState(publication)
            }
        }
    }
    

    
    @IBAction func buttonsActions (sender: UIButton!) {
    
        animateButton(sender)

        switch sender {

        case facebookButton:
            
            if let delegate = self.delegate {
                delegate.didRequestPostToFacebookForPublication()
            }
            
            GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Pulbisher facebook post button", label: "", value: 0)

        case twitterButton:
            if let delegate = self.delegate {
                delegate.didRequestPostToTwitterForPublication()
            }
            
            GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Pulbisher twitter post button", label: "", value: 0)

        case smsButton:

            print("smsButton")
            delegate?.publisherDidRequestSmsCollectors()
            
            GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Pulbisher sms button", label: "", value: 0)

            
        case phoneCallButton:

            print("phoneCallButton")
            delegate?.publisherDidRequestPhoneCall()
            
            GAController.sendAnalitics(kFAPublicationDetailsScreenName, action: "Pulbisher phone call button", label: "", value: 0)

            
        default:
            print("publication details unknown button")
        }
    }
    
    func configureInitialState(publication: Publication) {
        //User created publication
        if !publication.isOnAir!.boolValue {
            self.disableAllButtons()
            return
        }
        
        configureButtonsForNormalState()

        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        buttons = [facebookButton, twitterButton,smsButton, phoneCallButton]
        configureButtons()
    }
    
    func configureButtons() {
        
        for button in self.buttons {
            //button.backgroundColor = normalColor
            //button.setTitle("", forState: .Normal)
            button.layer.cornerRadius = CGRectGetWidth(button.frame) / 2
            button.enabled = true
        }
    }
        
    func disableAllButtons() {
        for button in self.buttons {
            button.backgroundColor = UIColor.lightGrayColor()
            button.enabled = false
        }
    }
    
    func configureButtonsForNormalState() {
        
        for button in buttons {
            button.backgroundColor = normalColor
            button.enabled = true
        }
    }
    
    private func animateButton(button: UIButton) {
        
        let scale = CGAffineTransformMakeScale(1.2, 1.2)
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8 , initialSpringVelocity: 0, options: [], animations: { () -> Void in
            
            button.transform = scale
            button.backgroundColor = self.buttonPressColor

        }) { (finished) -> Void in
            
                UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    
                    button.transform = CGAffineTransformIdentity
                    button.backgroundColor = self.normalColor
                    
                }) { (finished) -> Void in
                    
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateButtonsConstraints()
    }
    
    private func updateButtonsConstraints() {

        let buttonTotalWidth: CGFloat = 230
        let viewWidth = DeviceData.screenWidth()
        let margin = floor((viewWidth - buttonTotalWidth) / 3)
        let middleMargin = viewWidth - buttonTotalWidth - 2*margin
        
        self.button1to2widthConstraint.constant = margin
        self.button2to3widthConstraint.constant = middleMargin
        self.button3to4widthConstraint.constant = margin
        self.layoutIfNeeded()
    }
    
}
