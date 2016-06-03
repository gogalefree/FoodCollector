//
//  FCCollectorRootVC+Thumbnails.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension FCCollectorRootVC {
    
    func didSelectThumbnailForPublication(publication :Publication) {
    
        let coordinates = publication.coordinate
        let span   = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        self.mapView.setRegion(region, animated: true)
        guard let annotation = self.annotationForPublication(publication) else {return}
        self.mapView.selectAnnotation(annotation, animated: true)        
    }
    
    func annotationForPublication(publication: Publication) -> FDAnnotation? {
        
        var foundAnnotation: FDAnnotation? = nil
        
        for anotation in self.annotations {
            
            if anotation.publication.uniqueId!.integerValue == publication.uniqueId!.integerValue {
                
                foundAnnotation = anotation
                break
            }
        }
        
        return foundAnnotation
    }
}