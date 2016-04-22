//
//  UserProfileTextCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 21/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

protocol UserProfileTextCellDelegate: NSObjectProtocol{

    func didRequestEditing(indexPath: NSIndexPath)
    func didEndEditing(text: String? ,indexpath: NSIndexPath)
}

class UserProfileTextCell: UITableViewCell, UITextFieldDelegate {
    
    enum CellType {case NameCell , PhoneNumberCell}
    let kEditButtonTitle = NSLocalizedString("Edit", comment: "a button title meaning edit")
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mainLabel: UILabel!
  
    weak var delegate: UserProfileTextCellDelegate?
    var type: CellType = .NameCell
    var indexPath: NSIndexPath? {
        didSet{
            if indexPath != nil {setup()}
        }
    }

    func setup() {
    
        self.textField.alpha = 0
        self.mainLabel.alpha = 1
        switch type {
        case .NameCell:
            mainLabel.text = User.sharedInstance.userIdentityProviderUserName.capitalizedString
            textField.keyboardType = .NamePhonePad
            
        case .PhoneNumberCell:
            mainLabel.text = User.sharedInstance.userPhoneNumber
            textField.keyboardType = .PhonePad

        }
        
    }
    
    @IBAction func editActionTapped(sender: AnyObject) {
        self.setSelected(!self.selected, animated: true)
    }
    
    func setEditingMode() {
    
        self.textField.text = ""
        self.textField.becomeFirstResponder()
        delegate?.didRequestEditing(indexPath!)
        UIView.animateWithDuration(0.2) {
            self.editButton.setTitle(kDoneButtonTitle, forState: .Normal)
            self.textField.alpha = 1
            self.mainLabel.alpha = 0
        }
    }
    
    func setNormalState() {
        
        textField.resignFirstResponder()
        UIView.animateWithDuration(0.2) {
            self.editButton.setTitle(self.kEditButtonTitle, forState: .Normal)
            self.textField.alpha = 0
            self.mainLabel.alpha = 1
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.setSelected(!self.selected, animated: true)
        textField.resignFirstResponder()
        
        return true
    }
    
    func validateInputText() {
   
        let text = textField.text
        
        if text == nil || text == "" {return}
        
        if type == .PhoneNumberCell {
            
            let validator = Validator()
            let phoneNumber = validator.getValidPhoneNumber(text!)
            delegate?.didEndEditing(phoneNumber, indexpath: indexPath!)
            if phoneNumber != nil {
                mainLabel.text = phoneNumber
                textField.text = ""
            }
            
        } else {
            delegate?.didEndEditing(text, indexpath: indexPath!)
            mainLabel.text = text?.capitalizedString
            textField.text = ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            setEditingMode()
        } else {
            setNormalState()
            validateInputText()
        }
    }

}
