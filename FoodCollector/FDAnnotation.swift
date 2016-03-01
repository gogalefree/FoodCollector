//
//  FDAnnotation.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class FDAnnotation: NSObject,  MKAnnotation {

    let publication: Publication
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(publication: Publication) {
        
        self.publication = publication
        self.coordinate = publication.coordinate
        self.title = publication.title!
        self.subtitle = publication.subtitle
        
    }
}
