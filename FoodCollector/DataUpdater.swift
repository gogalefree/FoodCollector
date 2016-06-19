//
//  DataUpdater.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import Foundation

class DataUpdater: NSObject {
    
    var timer : NSTimer!
    
    func startUpdates() {
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60 * 1 , target: self, selector: #selector(DataUpdater.fetchData(_:)), userInfo: nil, repeats: true)
    }
    
    func fetchData(timer: NSTimer) {
     
        FCModel.sharedInstance.foodCollectorWebServer.downloadAllPublications()
    }
    
    deinit {
        self.timer.invalidate()
        self.timer = nil
    }
}
