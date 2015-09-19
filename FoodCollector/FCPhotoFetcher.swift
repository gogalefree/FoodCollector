//
//  FCPhotoFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 12/29/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import Foundation
import UIKit

class FCPhotoFetcher: NSObject {
    
    let foodCollectorProductionBucketName  = "foodcollector"
    let foodCollectorDevelopmentBucketName = "foodcollectordev"
    
    func fetchPhotoForPublication(publication: FCPublication , completion: (image: UIImage?)->Void) {
        
        var photo: UIImage? = nil
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let downloadedFilePath = FCModel.sharedInstance.photosDirectoryUrl.URLByAppendingPathComponent("/\(publication.photoUrl)")
        let downloadedFileUrl = NSURL.fileURLWithPath(downloadedFilePath.path!)
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket = self.bucketNameForBundle()//"foodcollector"
        downloadRequest.key = publication.photoUrl
        downloadRequest.downloadingFileURL = downloadedFileUrl
        
        transferManager.download(downloadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            
            if task.error != nil {
                print(task.error)
                completion(image: photo)
            }
            
            if task.result != nil {
                
                let downloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
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
    
    func uploadPhotoForPublication(publication : FCPublication) {
        
        let imageToUpload = publication.photoData.photo!
        let uploadFilePath = NSTemporaryDirectory().stringByAppendingString(publication.photoUrl)
        let uploadFileURL = NSURL.fileURLWithPath(uploadFilePath)
        
        UIImageJPEGRepresentation(imageToUpload,0)!.writeToURL(uploadFileURL, atomically: true)
        
        // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
        // the more it's compressed the smaller the file is
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = self.bucketNameForBundle() //"foodcollector"
        uploadRequest.key = publication.photoUrl;
        uploadRequest.body = uploadFileURL
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.error != nil {
                
             //   println("task error: \(task.error)")
            }
            
            if task.result != nil {
                
            //    println("success: \(task.result)")
            }
            
            return nil
        })
        
    }
    
    func bucketNameForBundle() -> String {
        
        var infoPlist: NSDictionary?
        var urlString: String
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType:"plist") {
            
            infoPlist = NSDictionary(contentsOfFile: path)
        }
        
        if let infoPlist = infoPlist {
            
            let bundleName = infoPlist["CFBundleName"] as! String
            print("bundle: \(bundleName)")
            if bundleName.hasPrefix("dev") {
                
                print("dev Version. buck is \(self.foodCollectorDevelopmentBucketName)")
                return self.foodCollectorDevelopmentBucketName
            }
        }
        
        print("prod or beta - bucket is \(self.foodCollectorProductionBucketName)")
        return self.foodCollectorProductionBucketName
    }
}
