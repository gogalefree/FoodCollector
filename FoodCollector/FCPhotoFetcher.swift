//
//  FCPhotoFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 12/29/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import Foundation


class FCPhotoFetcher: NSObject {
    
    
    func fetchPhotoForPublication(publication: FCPublication , completion: (image: UIImage?)->Void) {
        
        var photo: UIImage? = nil
        
        var transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let downloadedFilePath = FCModel.sharedInstance.photosDirectoryUrl.URLByAppendingPathComponent("/\(publication.photoUrl)")
        let downloadedFileUrl = NSURL.fileURLWithPath(downloadedFilePath.path!)
        
        var downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = "foodcollector"
        downloadRequest.key = publication.photoUrl
        downloadRequest.downloadingFileURL = downloadedFileUrl
        
        transferManager.download(downloadRequest).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
            
            println("inside the block")
            
            if task.error != nil {
                println(task.error)
                completion(image: photo)
            }
            
            if task.result != nil {
                
                let downloadOutput = task.result as AWSS3TransferManagerDownloadOutput
                println("success")
                photo = UIImage(contentsOfFile: downloadedFilePath.path!)
                publication.photoData.didTryToDonwloadImage = true
                if let publicationPhoto = photo {
                    publication.photoData.photo = publicationPhoto
                }
                completion(image: photo)
            }
            
            
            return nil
        })
    }
    
    deinit {
        println("DEINIT PHOTO FETCHER")
    }
    
}
