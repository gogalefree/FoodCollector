//
//  photoPresentorNavigationController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/11/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import UIKit

class FCPhotoPresentorNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .Custom

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
 //       self.navigationBar.layer.removeAllAnimations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
