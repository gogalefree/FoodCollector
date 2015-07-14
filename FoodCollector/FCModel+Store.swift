//
//  FCModel+Store.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

// MARK: - store

public extension FCModel {
    
    func savePublications() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let success = NSKeyedArchiver.archiveRootObject(self.publications, toFile: self.publicationsFilePath)
        }
    }
    
    func loadPublications() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            if NSFileManager.defaultManager().fileExistsAtPath(self.publicationsFilePath){
                let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.publicationsFilePath) as! [FCPublication]
                self.publications = array                
            }
        }
    }
    
    func saveUserCreatedPublications() {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let success = NSKeyedArchiver.archiveRootObject(self.userCreatedPublications, toFile: self.userCreatedPublicationsFilePath)
        }
    }
    
    func loadUserCreatedPublications() {
        
        if NSFileManager.defaultManager().fileExistsAtPath(self.userCreatedPublicationsFilePath){
            
            let array = NSKeyedUnarchiver.unarchiveObjectWithFile(self.userCreatedPublicationsFilePath) as! [FCPublication]
            self.userCreatedPublications = array
        }
    }
}
