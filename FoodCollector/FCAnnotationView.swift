//
//  FCAnnotationView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 12/30/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import MapKit

class FCAnnotationView: MKAnnotationView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
//    func imageForPublication(publication: FCPublication){
//        
//        switch publication.reportsForPublication.count {
//        
//        case 0...1:
//            greenImage(publication.typeOfCollecting)
//        
//        case 2...4:
//            orangeImage(publication.typeOfCollecting)
//        
//        default:
//            redImage(publication.typeOfCollecting)
//        }
//    }
//    
//    func greenImage(typeOfCollecting: FCTypeOfCollecting) {
//        
//        switch typeOfCollecting {
//     
//            case .ContactPublisher:
//                self.image = UIImage(named: "Green-Call")
//            default:
//                self.image = UIImage(named: "Green")
//        }
//    }
//    
//    func orangeImage(typeOfCollecting: FCTypeOfCollecting) {
//
//        switch typeOfCollecting {
//            
//        case .ContactPublisher:
//            self.image = UIImage(named: "Yellow-Call")
//        default:
//            self.image = UIImage(named: "Yellow")
//        }
//    }
//    
//    func redImage(typeOfCollecting: FCTypeOfCollecting) {
//        
//        switch typeOfCollecting {
//            
//        case .ContactPublisher:
//            self.image = UIImage(named: "Gray-Call")
//        default:
//            self.image = UIImage(named: "Gray")
//        }        
//    }
//    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
