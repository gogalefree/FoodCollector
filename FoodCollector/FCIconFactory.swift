//
//  FCIconFactory.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCIconFactory: NSObject {
    
    class func smallIconForPublication(publication: FCPublication) -> UIImage {
        
        var icon: UIImage
        
        switch publication.countOfRegisteredUsers {
            
        case 0...1:
           icon = self.greenImage()
            
        case 2...4:
            icon = self.orangeImage()
            
        default:
            icon = self.redImage()
        }
        
        return icon
    }
    
    class func greenImage() -> UIImage {
        
         let icon = UIImage(named: "Pin-Whole")!
        return icon
    }
    
    class func orangeImage() -> UIImage{
        
        let icon = UIImage(named: "Pin-Half")!
        return icon
    }
    
    class func redImage() -> UIImage {
        
        let icon = UIImage(named: "Pin-Few")!
        return icon
    }
    
    class func publicationsTableIcon() -> UIImage {
    
        let icon = UIImage(named: "Pin_Map_Marker")!
        
//        switch publication.countOfRegisteredUsers {
//            
//        case 0...1:
//            icon = UIImage(named: "Pin-Table-Whole")!
//            
//        case 2...4:
//            icon = UIImage(named: "Pin-Table-Half")!
//            
//        default:
//            icon = UIImage(named: "Pin-Table-Few")!
//        }
//        
        return icon
    }
    
    class func publicationDetailsReportIcon(report: PublicationReport) -> UIImage {
        
        var icon: UIImage
        
        switch report.report!.integerValue {
            
        case 1:
            icon = UIImage(named: "Pin-Table-Whole")!
            
        case 3:
            icon = UIImage(named: "Pin-Table-Half")!
            
        default:
            icon = UIImage(named: "Pin-Table-Few")!
        }
        
        return icon
    }
}
