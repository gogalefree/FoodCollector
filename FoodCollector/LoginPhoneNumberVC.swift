//
//  LoginPhoneNumberVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 20.1.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class LoginPhoneNumberVC: UIViewController {
    
    @IBOutlet weak var cellPhoneField: UITextField!
    
    @IBOutlet weak var profilePic: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func chnageImageButtonClicked(sender: UIButton) {
    }
    @IBAction func infoButtonClicked(sender: UIButton) {
    }
    
    @IBAction func stRTButtonClicked(sender: UIButton) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
