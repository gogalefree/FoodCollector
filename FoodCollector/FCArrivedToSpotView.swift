//
//  FCArrivedToSpotView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//

import UIKit
import Foundation

public struct FCOnSpotPublicationReport {
    
    var onSpotPublicationReportMessage:FCOnSpotPublicationReportMessage
    var date:NSDate
    
}

///
/// the report object can be:
/// 1. nothing left
/// 2. picked and some left
/// 3. picked and nothing left
///
enum FCOnSpotPublicationReportMessage: Int {
    
    case NothingThere = 5
    case TookAll = 3
    case HasMore = 1
    
}

protocol FCArrivedToSpotViewDelegate {
    
    func didReport(report:FCOnSpotPublicationReport ,forPublication publication:FCPublication)
}


///
/// presented to the user when they arrive at a publication’s spot
///

class FCArrivedToSpotView : UIView {
    
    var delegate:FCArrivedToSpotViewDelegate?
    var publication: FCPublication!
    
    
    func reportPublication(report: FCOnSpotPublicationReport) {
        
        if let myDelegate = self.delegate {
            myDelegate.didReport(report, forPublication: self.publication)
        }
    }
}

