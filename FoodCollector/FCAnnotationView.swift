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
    
    func imageForPublication(publication: FCPublication){
        
        switch publication.countOfRegisteredUsers {
        
        case 0...1:
            greenImage(publication.typeOfCollecting)
        
        case 2...4:
            orangeImage(publication.typeOfCollecting)
        
        default:
            redImage(publication.typeOfCollecting)
        }
    }
    
    func greenImage(typeOfCollecting: FCTypeOfCollecting) {
        
        switch typeOfCollecting {
     
            case .ContactPublisher:
                self.image = UIImage(named: "PinGreenCall")
            default:
                self.image = UIImage(named: "PinGreen")
        }
    }
    
    func orangeImage(typeOfCollecting: FCTypeOfCollecting) {

        switch typeOfCollecting {
            
        case .ContactPublisher:
            self.image = UIImage(named: "PinYellowCall")
        default:
            self.image = UIImage(named: "PinYellow")
        }
    }
    
    func redImage(typeOfCollecting: FCTypeOfCollecting) {
        
        switch typeOfCollecting {
            
        case .ContactPublisher:
            self.image = UIImage(named: "PinRedCall")
        default:
            self.image = UIImage(named: "PinRed")
        }        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
