//
//  DataController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 14/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//
import UIKit
import CoreData

class DataController:  NSObject  {

    var managedObjectContext: NSManagedObjectContext
    var managedObjectModel  : NSManagedObjectModel
    var managedModelURL            : NSURL
    
    override init() {
    
        
        // This resource is the same name as your xcdatamodeld contained in your project.
        
        guard let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        managedModelURL = modelURL
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        managedObjectModel = mom
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
        
            /* The directory the application uses to store the Core Data store file.
            This code uses a file named "DataModel.sqlite" in the application's documents directory.
            */
            
            let storeURL = docURL.URLByAppendingPathComponent("Model.sqlite")
            
            
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
                }
            }
        
        
    }
    
    func save() {
        
            managedObjectContext.performBlock({ () -> Void in
                do {
    
                try self.managedObjectContext.save()
                }
                catch  {
                    print("Managed Object Context Save Error \(error)")
                }
            })
        }

    func createPrivateQueueContext() -> NSManagedObjectContext {
        // Stack uses the same store and model, but a new persistent store coordinator and context.
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        /*
        Attempting to add a persistent store may yield an error--pass it out of
        the function for the caller to deal with.
        */
        do {
         
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            
            let storeURL = docURL.URLByAppendingPathComponent("Model.sqlite")
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            
        } catch {
            print("error creating private MOC in dataController")
            abort()
        }
        
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        context.persistentStoreCoordinator = coordinator
        
        context.undoManager = nil
        
        return context
    }
    
    
}