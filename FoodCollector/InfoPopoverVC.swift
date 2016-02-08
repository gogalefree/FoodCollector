//
//  InfoPopoverVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 8.2.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class InfoPopoverVC: UIViewController {
    
    let kInfoPopOverText = NSLocalizedString("Required for creating groups and finding friends. Your number is confidential and we will never expose it.", comment:"A small pop up information message that informs the user why we ask for his phone number")

    @IBOutlet weak var infoPopOverTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add text to info pop up UITextView
        // Text in UITextView in Interface Builder is exported to XLIFF, but the
        // localized translation is not displayed to the user. This is a known bug
        // in iOS for many versions. If we want this text to be displayed localized
        // in the UI, we need to set it using code.
        infoPopOverTextView.text = kInfoPopOverText
        infoPopOverTextView.font = UIFont(name: "Helvetica", size: 14.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
