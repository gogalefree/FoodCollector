//
//  ContactCollectorPhonePickerLabelCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 31/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class ContactCollectorPhonePickerLabelCell: UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!


    var validator = Validator()
    
    var registration: PublicationRegistration? {
        didSet{
            guard let registration = registration else {return}
            setup(registration)
        }
    }

    func setup(registration: PublicationRegistration) {
        
        self.mainLabel.text = registration.collectorName
        self.subtitleLabel.text = defineSubtitle()
        if subtitleLabel.text != "" {self.userInteractionEnabled = false}
        self.mainLabel.font = UIFont.systemFontOfSize(15)
    }
    
    func defineSubtitle() -> String {
    
        guard let _ =  validator.getValidPhoneNumber(registration!.collectorContactInfo!) else {return NSLocalizedString("Incorrect phone number", comment: "Message alert when phone number pattern is incorrect")}
        return ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.subtitleLabel.text = ""
        self.mainLabel.text = ""
        self.userInteractionEnabled = true
        self.seperatorView.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
