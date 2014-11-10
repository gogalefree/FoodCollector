//
//  FCAppDataStoreManager.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import Foundation

///
/// Handles all persistency of the app.
/// when the app launches, it uses the stored data until fetch operation is
///  completed.
///

class FCAppDataStoreManager : NSObject {
    
    var stroreFileUrl:String = ""
    var userCreatedPublicationsFileUrl:String?
    var publications = [FCPublication]()
    var userCreatedPublications = [FCPublication]()
    
   
    ///
    /// called when a user deletes a publication that was created by him.
    ///
    func deleteUserCreatedPublication(publication:FCPublication)->Bool {
        return false
        
    }
    
    ///
    /// save all publications array to disk
    ///
    func savePublications() {
        
    }
    
    ///
    /// saves a newly created publication by user
    ///
    func saveUserCreatedPublication(publication: FCPublication) {
        
    }
    
    ///
    /// loads all publications from disk
    ///
    func loadPublications()->[FCPublication] {
        return [FCPublication]()
        
    }
    
    ///
    /// loads the user created publications from disk
    ///
    func loadUserCreatedPublications()->[FCPublication] {
        return [FCPublication]()
        
    }
    
}

