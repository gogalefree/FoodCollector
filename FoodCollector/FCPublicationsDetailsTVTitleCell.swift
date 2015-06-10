//
//  FCPublicationsDetailsTVTitleCellTableViewCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

protocol FCPublicationDetailsTitleCellDelegate {
    func didRegisterForPublication(publication: FCPublication)
    func didUnRegisterForPublication(publication: FCPublication)
    func didRequestNavigationForPublication(publication: FCPublication)
}

enum RegisterButtonState {
    case Registered
    case Unregistered
}

let registerButtonTitleForUnregisteredState = String.localizedStringWithFormat("הרשם" , "regiterration button title meening register")

let registerButtonTitleForRegisteredState = String.localizedStringWithFormat("הסר" , "regiterration button title meening unregister")

let navigationButtonTitle = String.localizedStringWithFormat("נווט" , "navigation button title meening take me to the destination")


class FCPublicationsDetailsTVTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registeredUsersLabel: UILabel!
    var navigationButton: UIButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    var delegate: FCPublicationDetailsTitleCellDelegate? //publicationDetailsTVC
    
    var publication: FCPublication? {
        
        didSet {
            
            if let publication = self.publication{
                self.titleLabel.text = publication.title
                self.subtitleLabel.text = publication.subtitle
                self.addressLabel.text = self.makeDistanceText(publication)
                
                if FCModel.sharedInstance.isUserCreaetedPublication(publication){
                    self.registerButton.alpha = 0
                }
                else {

                    if publication.didRegisterForCurrentPublication {
                        self.configureRegisterButtonForState(.Registered)
                    }
                    else {
                        self.configureRegisterButtonForState(.Unregistered)
                    }
                }
            }
        }
    }
    
    @IBAction func registerButtonAction(sender: AnyObject) {
        
        if let publication = self.publication{
            
            if publication.didRegisterForCurrentPublication == true {
                
                self.unRegisterForPublication(publication)
            }
            else {
                
                self.registerForPublication(publication)
            }
        }
    }
    
    func registerForPublication(publication: FCPublication) {
       
        self.configureRegisterButtonForState(RegisterButtonState.Registered)
        if let delegate = self.delegate {
            delegate.didRegisterForPublication(publication)
        }
    }
    
    func unRegisterForPublication(publication: FCPublication) {
       
        self.configureRegisterButtonForState(RegisterButtonState.Unregistered)
        if let delegate = self.delegate {
            delegate.didUnRegisterForPublication(publication)
        }
    }
    
    func configureRegisterButtonForState(state: RegisterButtonState) {
        switch state {
            
        case .Registered:
           
            self.registerButton.setTitle(registerButtonTitleForRegisteredState, forState: UIControlState.Normal)
            showNavigationButton()
        case .Unregistered:
            
            self.registerButton.backgroundColor = UIColor.clearColor()
            self.registerButton.setTitle(registerButtonTitleForUnregisteredState, forState: UIControlState.Normal)
            hideNavigationButton()
            
        }
    }
    
    func showNavigationButton() {
        navigationButton.center = self.registerButton.center
        let currentCenterY = self.navigationButton.center.y
        let currentCenterX = self.navigationButton.center.x
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil , animations: { () -> Void in
            self.navigationButton.alpha = 1
            self.navigationButton.center = CGPointMake(currentCenterX, currentCenterY + 60)
            self.registerButton.layer.borderColor = UIColor.greenColor().CGColor
            self.navigationButton.layer.borderColor = UIColor.greenColor().CGColor

        }, completion: nil)
    }
    
    func hideNavigationButton() {

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.navigationButton.center = self.registerButton.center
            self.registerButton.layer.borderColor = UIColor.blueColor().CGColor
            self.navigationButton.layer.borderColor = UIColor.blueColor().CGColor
            self.navigationButton.alpha = 0
            
            }) { (completed) -> Void in}
    }
    
    func navigate(sender: UIButton) {
        self.delegate?.didRequestNavigationForPublication(self.publication!)
    }
    
    func configureNavigationButtonInitialState() {
        
        self.navigationButton.frame = self.registerButton.frame
        self.navigationButton.frame.size.height = 50
        self.navigationButton.layer.cornerRadius = self.navigationButton.bounds.width / 2
        self.navigationButton.layer.borderColor = UIColor.blueColor().CGColor
        self.navigationButton.layer.borderWidth = 1
        self.contentView.addSubview(navigationButton)
        self.navigationButton.setTitle(navigationButtonTitle, forState: .Normal)
        self.navigationButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.navigationButton.tintColor = UIColor.blueColor()
        navigationButton.addTarget(self, action: "navigate:", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationButton.alpha = 0
    }
    
    func makeDistanceText(publication: FCPublication) -> String {
        
        let addressString = publication.address
        let distanceString = FCStringFunctions.longDistanceString(publication)
        let displayedString = addressString + "\n" + distanceString
        return displayedString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        self.subtitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        self.addressLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        
        self.titleLabel.numberOfLines = 0
        self.subtitleLabel.numberOfLines = 0
        self.addressLabel.numberOfLines = 0
        
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1 , constant: 140))
        
        self.registerButton.layer.cornerRadius = self.registerButton.bounds.size.width / 2
        self.registerButton.layer.borderColor = UIColor.blueColor().CGColor
        self.registerButton.layer.borderWidth = 1
        
        configureNavigationButtonInitialState()
        
        }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
}
