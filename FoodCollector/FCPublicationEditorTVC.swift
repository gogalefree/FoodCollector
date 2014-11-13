//
//  FCPublicationEditorTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import Foundation
import UIKit
import CoreLocation


/// represents the cell data of the editor.

struct FCNewPublicationTVCCellData {
    
    var height:CGFloat
    var containsUserData:Bool
    var initialTitle:String
    var isObligatory:Bool
    var userData:AnyObject
    var newPublicationTVC:FCPublicationEditorTVC
    
}

enum FCPublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
    
}

public enum FCTypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}

///
/// handles the creation of a new publication or the editing of an existing
///  one.
///
class FCPublicationEditorTVC : UITableViewController,FCPublicationDataInputDelegate {
    
        
    var publication:FCPublication?
    var dataSource = [FCNewPublicationTVCCellData]()
    var state: FCPublicationEditorTVCState!
    
    
    
    // MARK: - PublicationDataInputDelegate protocol
    
    
    func initWithState(state:FCPublicationEditorTVCState, publication:FCPublication?) {
        
    }
    
    ///
    /// this method is called when a new publication is ready to be published,
    ///  or when a user edited an existing publication. editing an existing publication
    ///  will result with a new publication with a unique id with the same id and
    ///  a different version number.
    ///
    func publish() {
        
    }
    
    ///
    /// UIPhotoPickerDelegate
    ///
    func didFinishPickingPhoto(photo:UIImage) {
        
    }
    
    /// Mark - FCPublicationDataInputDelegate
    
    func didPickSubtitle(subtitle:String){
        
    }
    
    func didPickDate(date:NSDate){
        
    }
    
    func didPickTitle(title:String) {
        
    }
    
    func didPickTypeOfCollection(typeOfCollection: FCTypeOfCollecting ,withContactInfo contactinfo:String) {
        
    }
    
    func didPickAddress(address:String,withLocation coordinates:CLLocationCoordinate2D) {
        
    }
}

