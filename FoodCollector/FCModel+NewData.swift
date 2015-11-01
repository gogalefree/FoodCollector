//
//  FCModel+NewData.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation

extension FCModel {
    
    func downloadData() {
        
        self.foodCollectorWebServer.downloadAllPublicationsWithCompletion
            { (thePublications: [FCPublication]) -> Void in
                
                self.fetchedPublications = thePublications

                self.newPublications.removeAll()
                self.publicationsToDelete.removeAll()
                self.prepareNewData()
        }
    }
    

    func prepareNewData() {
        
        //check didRegisterPublication and publicationReports
        let prepareDataQperation = NSBlockOperation { () -> Void in
            
            for fetchedPublication in self.fetchedPublications {
                              
                for publication in self.publications {
                    
                    if fetchedPublication.uniqueId == publication.uniqueId &&
                        fetchedPublication.version == publication.version {
                          
                            fetchedPublication.didRegisterForCurrentPublication = publication.didRegisterForCurrentPublication
                            fetchedPublication.reportsForPublication = publication.reportsForPublication
                            fetchedPublication.photoData.photo = publication.photoData.photo
                            fetchedPublication.photoData.didTryToDonwloadImage = publication.photoData.didTryToDonwloadImage
                            fetchedPublication.countOfRegisteredUsers = publication.countOfRegisteredUsers
                            break
                    }
                }
            }
        }
        
        //sort new publications operation
        let newPublicationsOperation = NSBlockOperation { () -> Void in
         
            self.newPublications = FCFetchedDataSorter.publicationToAdd(self.fetchedPublications)
        }
        
        newPublicationsOperation.addDependency(prepareDataQperation)
        
        //sort publications to delete operation
        let publicationsToDeleteOperation = NSBlockOperation { () -> Void in
            
            self.publicationsToDelete = FCFetchedDataSorter.publicationsToDelete(self.fetchedPublications)
        }
        
        publicationsToDeleteOperation.addDependency(newPublicationsOperation)

        
        //if two publications are in the same coordinates, we chamge on of them by 40 m
        //if the user registers and navigates - we change it back to the right coords
        let checkIfTwoPublicationsInTheSameCoordinatesOperation = NSBlockOperation { () -> Void in
            
            if self.fetchedPublications.count >= 1 {
            
            for index in 0..<(self.fetchedPublications.count - 1) {
                
                let publication = self.fetchedPublications[index]
                               
                for var i = index ; i < (self.fetchedPublications.count - 2) ; ++i {
                    
                    let anotherPublication = self.fetchedPublications[i+1]
                    if publication.coordinate.latitude == anotherPublication.coordinate.latitude &&
                        publication.coordinate.longitude == anotherPublication.coordinate.longitude {
                            
                            publication.coordinate.latitude += kModifyCoordsToPresentOnMapView
                            publication.coordinate.longitude += kModifyCoordsToPresentOnMapView
                            publication.didModifyCoords = true
                    }
                }
            }
            }
        }
        
        checkIfTwoPublicationsInTheSameCoordinatesOperation.addDependency(prepareDataQperation)
        
        let fetchPublicationsRegistrationsOperation = NSBlockOperation { () -> Void in
            
            for publication in self.fetchedPublications {
                
                let registrationFetcher = FCPublicationRegistrationsFetcher(publication: publication)
                registrationFetcher.fetchPublicationRegistration(true)
            }
        }
        
        fetchPublicationsRegistrationsOperation.addDependency(checkIfTwoPublicationsInTheSameCoordinatesOperation)
        
        let fetchPublicationReportsOperation = NSBlockOperation { () -> Void in
            
            let counter = self.fetchedPublications.count - 1
            for (index , publication) in self.fetchedPublications.enumerate() {
                FCModel.sharedInstance.foodCollectorWebServer.reportsForPublication(publication, completion: { (success, reports) -> () in
                    
                    if success {
                        if publication.didRegisterForCurrentPublication && publication.reportsForPublication.count < reports!.count {publication.didRecieveNewReport = true}
                        publication.reportsForPublication = reports!
                    }
                    if counter == index {
                        FetchedDataNotificationsController.shared.prepareNotificationsFromWebFetch()
                        self.postFetchedDataReadyNotification()
                    }
                })
            }
        }
                
        fetchPublicationReportsOperation.addDependency(fetchPublicationsRegistrationsOperation)
        fetchPublicationReportsOperation.completionBlock = {
            
            self.publications = self.fetchedPublications
            self.savePublications()
            self.saveUserCreatedPublications()
        }
        
        //add fetch number of registered users for publication
        
        let prepareDataQue = NSOperationQueue.mainQueue()
        prepareDataQue.qualityOfService = .Background
        prepareDataQue.addOperations([prepareDataQperation,publicationsToDeleteOperation, newPublicationsOperation ,checkIfTwoPublicationsInTheSameCoordinatesOperation, fetchPublicationReportsOperation, fetchPublicationsRegistrationsOperation ], waitUntilFinished: false)
    }
}
