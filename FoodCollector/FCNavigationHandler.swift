//
//  FCNavigationHandler.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//
//  SingleTone


import Foundation
import MapKit

///
/// responsible for navigation logic with Waze or Apple Maps
///
class FCNavigationHandler : NSObject {
    
    func wazeNavigation(publication: FCPublication){
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string:"waze://")!){
            
            var latitude = publication.coordinate.latitude
            var longitude = publication.coordinate.longitude
            
            if publication.didModifyCoords {
                latitude -= kModifyCoordsToPresentOnMapView
                longitude -= kModifyCoordsToPresentOnMapView
            }
            
            let navString = "waze://?ll=\(latitude),\(longitude)&navigate=yes"
            UIApplication.sharedApplication().openURL(NSURL(string:navString)!)
        }
    }
    
    func appleMapsNavigation(publication: FCPublication) {
        
        var latitude = publication.coordinate.latitude
        var longitude = publication.coordinate.longitude
        
        if publication.didModifyCoords {
            latitude -= kModifyCoordsToPresentOnMapView
            longitude -= kModifyCoordsToPresentOnMapView
        }
        
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        
        let destinationPM = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: destinationPM)
        destinationItem.name = publication.title
        let userCoordinates = FCModel.sharedInstance.userLocation.coordinate
        let currentPM = MKPlacemark(coordinate:userCoordinates , addressDictionary: nil)
        let currentItem = MKMapItem(placemark: currentPM)
        currentItem.name = "You're Here"
        
        let navItems = [currentItem , destinationItem]
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMapsWithItems(navItems, launchOptions: launchOptions)
    }
}



extension FCNavigationHandler {
    
    //SingleTone Shared Instance
    class var sharedInstance : FCNavigationHandler {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FCNavigationHandler? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = FCNavigationHandler()
        }
        return Static.instance!
    }
}
