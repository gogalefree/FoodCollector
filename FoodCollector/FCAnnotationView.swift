//
//  FCAnnotationView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 12/30/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import MapKit

class FCAnnotationView: MKPinAnnotationView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    func imageForPublication(publication: FCPublication){
        
        var image: UIImage
        
        switch publication.countOfRegisteredUsers {
        case 0...1:
            image = UIImage(named: "easter_cake-26.png")!
        case 2...4:
            image = UIImage(named: "easter_rabbit-26.png")!
        default:
            image = UIImage(named: "bell-26.png")!
        }
        
        self.image = image
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
