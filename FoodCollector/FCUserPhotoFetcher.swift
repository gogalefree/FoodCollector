//
//  FCUserPhotoFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/01/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

class FCUserPhotoFetcher: NSObject {

    let foodCollectorProductionBucketName  = "foodonetusers"
    let foodCollectorDevelopmentBucketName = "foodonetusersdev"
    
    func userPhotoForPublication(publication: FCPublication , completion: (image: UIImage?)->Void) {
        
        var photo: UIImage? = nil
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let downloadedFilePath = FCModel.sharedInstance.photosDirectoryUrl.URLByAppendingPathComponent("/\(publication.photoUrl)")
        let downloadedFileUrl = NSURL.fileURLWithPath(downloadedFilePath.path!)
        
        let downloadRequest                 = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket              = self.bucketNameForBundle()//"foodcollector"
        downloadRequest.key                 = publication.photoUrl
        downloadRequest.downloadingFileURL  = downloadedFileUrl
        
        transferManager.download(downloadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            
            if task.error != nil {
                print(task.error)
                completion(image: photo)
            }
            
            if task.result != nil {
                
                //let downloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
                photo = UIImage(contentsOfFile: downloadedFilePath.path!)
//                publication.photoData.didTryToDonwloadImage = true
//                if let publicationPhoto = photo {
//                    publication.photoData.photo = publicationPhoto
//                }
                completion(image: photo)
            }
            
            
            return nil
        })
    }
    
    func uploadUserPhoto() {
        
        let photo = UIImage(named: "UserGreen")

        let imageToUpload = photo!
        let uploadFilePath = NSTemporaryDirectory().stringByAppendingString("usertry1.jpg") //user.userID
        let uploadFileURL = NSURL.fileURLWithPath(uploadFilePath)

        
        UIImageJPEGRepresentation(imageToUpload,1)!.writeToURL(uploadFileURL, atomically: true)
        
        // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
        // the more it's compressed the smaller the file is
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = self.bucketNameForBundle() //"foodcollector"
        uploadRequest.key = "usertry1.jpg"
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
    
    func deleteUserPhotoForPublication() {
        
/*
        //Delete Object
        let deletePhotoRequest      = AWSS3DeleteObjectRequest()
        deletePhotoRequest.bucket   = self.bucketNameForBundle()
        deletePhotoRequest.key      = publication.photoUrl
        
        let s3 = AWSS3.defaultS3()
        let task = s3.deleteObject(deletePhotoRequest)
        print(task.description)
*/
    }
    
    func bucketNameForBundle() -> String {
        
        var infoPlist: NSDictionary?
        
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
