//
//  ContactCollectorPhonePickerVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 31/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class ContactCollectorPhonePickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var registrations = [FCRegistrationForPublication]()
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    //MARK: table view datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section != 1 {return 1}
        return registrations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCollectorPhonePickerLabelCell", forIndexPath: indexPath) as! ContactCollectorPhonePickerLabelCell

        switch indexPath.section {
            
        case 0:
            //title cell
            cell.mainLabel.text = String.localizedStringWithFormat("התקשר לאוסף:", "")
            cell.mainLabel.font = UIFont.boldSystemFontOfSize(17)
            cell.subtitleLabel.text = ""
            cell.userInteractionEnabled = false
            cell.seperatorView.backgroundColor = UIColor.blackColor()
            return cell
            
        case 1:
            cell.registration  = registrations[indexPath.row]
            return cell
            
        default :
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            callIndexPath(indexPath)
        default:
            break
        }
    }
    
    func callIndexPath(indexpath: NSIndexPath) {
        
        let registration = registrations[indexpath.row]
        
        if let phoneNumber = validator.getValidPhoneNumber(registration.contactInfo) {
            
            let telUrl = NSURL(string: "tel://\(phoneNumber)")!
            
            if UIApplication.sharedApplication().canOpenURL(telUrl){
                
                UIApplication.sharedApplication().openURL(telUrl)
            }
        }
    }


    @IBAction func dismiss() {
    
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
