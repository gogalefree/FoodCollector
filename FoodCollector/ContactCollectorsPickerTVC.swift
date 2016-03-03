//
//  ContactCollectorsPickerTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 31/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit
import Foundation
import MessageUI


class ContactCollectorsPickerTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
    let kSendSMSNotSelectedAlertTitle = NSLocalizedString("No collectors were selected", comment:"Alert message title")
    

    @IBOutlet weak var tableView: UITableView!
    
    var registrations  = [PublicationRegistration]()
    var userSelections = [Bool]()
    
    var publication: Publication? {
        didSet {
            if let publication = publication {setup(publication)}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func setup(publication: Publication) {
    
        guard let registrations = publication.registrations else {return}
        let validator = Validator()
        let registrationsArray = Array(registrations) as! [PublicationRegistration]
        self.registrations = registrationsArray.filter {(registration) in validator.getValidPhoneNumber(registration.collectorContactInfo!) != nil}
        for _ in self.registrations  {userSelections.append(Bool(false))}
    }
    
    //MARK: - TableView Data Source
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        if section != 0 { view.backgroundColor = UIColor.clearColor()}
        return view
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = UIColor.whiteColor()
            return view
        }
        
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section != 1 {return 1}
        return registrations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
            
        case 0:
            //select all cell
            let cell = tableView.dequeueReusableCellWithIdentifier("collectorDetailsCell", forIndexPath: indexPath) as? ContactCollectorPickerCollectorDetailsCell
            let chosen = didSelectAll()
            cell!.chosen = chosen
            cell?.indexPath = indexPath
            cell?.layer.cornerRadius = 5

            return cell!
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("collectorDetailsCell", forIndexPath: indexPath) as! ContactCollectorPickerCollectorDetailsCell
            cell.chosen = userSelections[indexPath.row]
            cell.registration = self.registrations[indexPath.row]
            cell.indexPath = indexPath

            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("sendSmsToCollectorsCell", forIndexPath: indexPath) as! ContactCollectorsPickerSendSmsCell
            cell.mainLabel.text = NSLocalizedString("Send Message", comment:"Send a message to a colllector")
            cell.layer.cornerRadius = 5
            return cell
            
        default :
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        switch indexPath.section {
            
        case 0:
            //select all cell
            selectAllCellChosen()
            tableView.reloadData()
            
        case 1:
            deselectAllCell()
            changeUserSelectionForIndexPath(indexPath)
            
        case 2:
            sendSms()
            
        default:
            break
        }
    }
    
    func sendSms() {
        
        var recipients = [String]()
        for (index ,selected) in userSelections.enumerate() {
            if selected {recipients.append(registrations[index].collectorContactInfo!)}
        }
        
        if recipients.count == 0 {
        
            let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(kSendSMSNotSelectedAlertTitle, aMessage: "")
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if MFMessageComposeViewController.canSendText() {
            
            let messageVC = MFMessageComposeViewController()
            messageVC.body = ""
            messageVC.recipients = recipients
            messageVC.messageComposeDelegate = self
            self.navigationController?.presentViewController(messageVC, animated: true, completion: nil)
        }
    }
    
    func changeUserSelectionForIndexPath(indexPath: NSIndexPath) {
    
        userSelections[indexPath.row] = !userSelections[indexPath.row]
    }
    
    func selectAllCellChosen() {
        
        let allSelected = didSelectAll()
        changeAllSelections(!allSelected)
    }
    
    func deselectAllCell() {
    
        let indexpath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexpath) as! ContactCollectorPickerCollectorDetailsCell
        cell.chosen = false
        cell.reloadImage()
    }
    
    func changeAllSelections(selection: Bool) {
        
        for index in 0...userSelections.count - 1 {userSelections[index] = selection}
    }
    
    func didSelectAll() -> Bool {
        
        for userSelection in userSelections {
            if userSelection == false {return false}
        }
        return true
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
            
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
        case MessageComposeResultFailed.rawValue:
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
            
            let alert = UIAlertController(title: kSendSMSfailedAlertTitle, message: kSendSMSTryAgainAlertMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: kYesButtonTitle, style: .Default , handler: { (action) -> Void in
                self.sendSms()
            }))
            alert.addAction(UIAlertAction(title: kNoButtonTitle, style: .Cancel, handler: { (action) -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

        default:
            break;
        }
    }
    
    @IBAction func didCancelSMSVC() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
