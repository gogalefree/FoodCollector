//
//  AboutVC.swift
//  FoodCollector
//
//  Created by Artyom on 11.03.15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet var aboutView: UIView!
    
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblBuild: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        lblVersion.text = version()
        lblBuild.text = build()
    }

    
    func version() -> String {
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as String
        
        return "\(version)"
    }
    
    func build() -> String {
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let build = dictionary["CFBundleVersion"] as String
        
        return "\(build)"
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
