//
//  FCLaunchScreenView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/27/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCLaunchScreenView: UIView {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        
        if let path = NSBundle.mainBundle().pathForResource("info", ofType:"plist") {
            
            let plist = NSDictionary(contentsOfFile: path)
            let version = plist?.objectForKey("CFBundleVersion") as String
            self.versionLabel.text = version
            print("version ++++++++ \(version)")
            
        }
        
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
