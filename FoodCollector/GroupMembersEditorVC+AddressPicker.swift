//
//  GroupMembersEditorVC+AddressPicker.swift
//  FoodCollector
//
//  Created by Guy Freedman on 18/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

extension GroupMembersEditorVC {
    
    
   
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        var memberName          = ""
        var memberPhoneNumber   = ""
        
        //first name
        let firstNameTemp = ABRecordCopyValue(person, kABPersonFirstNameProperty)
        
        if firstNameTemp != nil {
        let firstName: NSObject? = Unmanaged<NSObject>.fromOpaque(firstNameTemp.toOpaque()).takeRetainedValue()
        
        if let firstName = firstName{
            memberName = firstName as! String
            print("firstName: \(firstName)")
        }
        else {print("fristName is nil")}
        }
        
        //last name
        let lastNameTemp = ABRecordCopyValue(person, kABPersonLastNameProperty)
        if let lastNameTemp = lastNameTemp {
            
            let lastName: NSObject? = Unmanaged<NSObject>.fromOpaque(lastNameTemp.toOpaque()).takeRetainedValue()
            
            if let lastName = lastName {
                memberName = memberName + " " + (lastName as! String)
                print("first name including lastName: \(memberName)")
            }
        }
            
        else {print("lastName is nil")}
        
        //phone number
        var pho: ABMultiValueRef
        let phoneV : Unmanaged<AnyObject>? = ABRecordCopyValue(person, kABPersonPhoneProperty)
        
        if let phonehasv = phoneV {
            pho = phonehasv.takeUnretainedValue() as ABMultiValueRef
            
            
            if ABMultiValueGetCount(pho) > 0 {
                
                let phones: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue() as ABMultiValueRef
                
                for index in 0 ..< ABMultiValueGetCount(phones){
                    
                    let currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phones, index).takeUnretainedValue() as CFStringRef as String
                    let currentPhoneValue = ABMultiValueCopyValueAtIndex(phones, index).takeUnretainedValue() as! CFStringRef as String
                    
                    memberPhoneNumber = currentPhoneValue
                    print("phone value \(currentPhoneValue)")
                    print("phone label \(currentPhoneLabel)")
                    break
                }
            }
        }
        print("final name: \(memberName)")
        print("final phone: \(memberPhoneNumber)")
        
        updateMembers(memberName , memberPhoneNumber: memberPhoneNumber)
        
    }
    
    func updateMembers(memberName: String, memberPhoneNumber: String) {
        
        if memberPhoneNumber.isEmpty || memberName.isEmpty {
        
            self.showEmptyValuesAlert()
            return
        }
        tableView.alpha = 1
        let groupMemberData = GroupMemberData(name: memberName, phoneNumber: memberPhoneNumber)
        self.members.insert(groupMemberData, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        self.tableView.setEditing(false, animated: true)
    }
    
    func showEmptyValuesAlert() {
        
        let message = NSLocalizedString("Contact has no name or phone number.", comment: "Alert message when adding a member to a group that has no name or phone number.")
        let alertController = UIAlertController(title: kOopsAlertTitle, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: kOKButtonTitle, style: .Cancel) { (_) in alertController.dismissViewControllerAnimated(true, completion: nil)}
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}