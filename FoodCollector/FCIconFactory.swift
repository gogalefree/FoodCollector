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
           icon = self.greenImage(publication.typeOfCollecting)
            
        case 2...4:
            icon = self.orangeImage(publication.typeOfCollecting)
            
        default:
            icon = self.redImage(publication.typeOfCollecting)
        }
        
        return icon
    }
    
    class func greenImage(typeOfCollecting: FCTypeOfCollecting) -> UIImage {
        
        var icon: UIImage
        
        switch typeOfCollecting {
            
        case .ContactPublisher:
            icon = UIImage(named: "Green-Call")!
        default:
            icon = UIImage(named: "Green")!
        }
        
        return icon
    }
    
    class func orangeImage(typeOfCollecting: FCTypeOfCollecting) -> UIImage{
        
        var icon: UIImage

        switch typeOfCollecting {
            
        case .ContactPublisher:
            icon = UIImage(named: "Yellow-Call")!
        default:
            icon = UIImage(named: "Yellow")!
        }
        
        return icon
    }
    
    class func redImage(typeOfCollecting: FCTypeOfCollecting) -> UIImage {
        
        var icon: UIImage

        switch typeOfCollecting {
            
        case .ContactPublisher:
            icon = UIImage(named: "Gray-Call")!
        default:
            icon = UIImage(named: "Gray")!
        }
        
        return icon
    }

   
}
