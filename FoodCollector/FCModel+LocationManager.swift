//
//  FCModel+LocationManager.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation
import CoreLocation

extension FCModel {
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
            
        case  .AuthorizedWhenInUse :
            self.setupLocationManager()
        default:
            break
        }
    }
    
    func setupLocationManager() {
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kDistanceFilter
        self.locationManager.startUpdatingLocation()
    }
    
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.userLocation = locations.last!
    }
    
    public func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?){
        print(error)
    }
}