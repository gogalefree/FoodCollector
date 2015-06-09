//
//  PublicationDetsilsActionsHeaderView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 6/8/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import Foundation

protocol PublicationDetailsActionsHeaderDelegate: NSObjectProtocol {
    
    func didRegisterForPublication(publication: FCPublication)
    func didUnRegisterForPublication(publication: FCPublication)
    func didRequestNavigationForPublication(publication: FCPublication)
    func didRequestPhoneCallForPublication(publication: FCPublication)
    func didRequestSmsForPublication(publication: FCPublication)
}

class PublicationDetsilsActionsHeaderView: UIView {
    
    @IBOutlet weak var registerButton:  UIButton!
    @IBOutlet weak var navigateButton:  UIButton!
    @IBOutlet weak var smsButton:       UIButton!
    @IBOutlet weak var phoneCallButton: UIButton!
    
    weak var delegate: PublicationDetailsActionsHeaderDelegate!
    
    var buttons = [UIButton]()
    
    var publication: FCPublication! {
        didSet {
            if let publication = self.publication {
                configureInitialState(publication)
            }
        }
    }
    

    
    @IBAction func buttonsActions (sender: UIButton!) {
    
        switch sender {
            
        case registerButton:
            println("publication details register button")
            
        case navigateButton:
            println("publication details navigate button")
            
        case smsButton:
            println("publication details sms button")
            
        case phoneCallButton:
            println("publication details phone call button")
            
        default:
            println("publication details unknown button")
        }
    }
    
    func configureInitialState(publication: FCPublication) {
        //User created publication
        if FCModel.sharedInstance.isUserCreaetedPublication(publication){
            self.disableAllButtons()
        }
        //User is registered
        else if !publication.didRegisterForCurrentPublication {
            configureButtons()
        }
        //User is not registered
        else {
           configureButtonsForUnregisteredUser()
        }
        if publication.typeOfCollecting != .ContactPublisher {
            
            configureButtonsForFreePickup()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        buttons = [registerButton, navigateButton,smsButton, phoneCallButton]
        configureButtons()
    }
    
    func configureButtons() {
        
        for button in self.buttons {
            
            let buttonColor = UIColor(red: 49/255, green: 151/255, blue: 211/255, alpha: 1)
            button.backgroundColor = buttonColor
            button.setTitle("", forState: .Normal)
            button.layer.cornerRadius = CGRectGetWidth(button.frame) / 2
            button.enabled = true
        }
    }
    
    func disableAllButtons() {
        for button in self.buttons {
            
            let buttonColor = UIColor.lightGrayColor()
            button.backgroundColor = buttonColor
            button.enabled = false
        }
    }
    
    func configureButtonsForUnregisteredUser() {
     
        for button in self.buttons {
            
            let buttonColor = UIColor.lightGrayColor()
            button.backgroundColor = buttonColor
            button.enabled = true
        }
    }
    
    final func configureButtonsForFreePickup() {
        let contactButtons = [smsButton , phoneCallButton]
        for button in contactButtons {
            
            let buttonColor = UIColor.lightGrayColor()
            button.backgroundColor = buttonColor
            button.enabled = false
        }
    }
}
