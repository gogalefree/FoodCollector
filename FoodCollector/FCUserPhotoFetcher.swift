//
//  FCUserPhotoFetcher.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/01/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

class FCUserPhotoFetcher: NSObject {
    let kUserPhotoKeyPrefix                = "fduser"
    let foodCollectorProductionBucketName  = "foodonetusers"
    let foodCollectorDevelopmentBucketName = "foodonetusersdev"
    
    func userPhotoForPublication(publication: Publication , completion: (image: UIImage?)->Void) {

        
        let photoKey = kUserPhotoKeyPrefix + "\(publication.publisherId!.integerValue)" + ".jpg"

        var photo: UIImage? = nil
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let downloadedFilePath = FCModel.sharedInstance.photosDirectoryUrl.URLByAppendingPathComponent("/\(photoKey)")
        let downloadedFileUrl = NSURL.fileURLWithPath(downloadedFilePath.path!)
        
        let downloadRequest                 = AWSS3TransferManagerDownloadRequest()
        downloadRequest.bucket              = self.bucketNameForBundle()//"foodcollector"
        downloadRequest.key                 = photoKey
        downloadRequest.downloadingFileURL  = downloadedFileUrl
        
        transferManager.download(downloadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            
            if task.error != nil {
                print(task.error)
                completion(image: photo)
            }
            
            if task.result != nil {
                
                //let downloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
                photo = UIImage(contentsOfFile: downloadedFilePath.path!)
                if photo != nil {
                    publication.publisherPhotoData = UIImageJPEGRepresentation(photo!, 1)
                    FCModel.dataController.save()
                }
                completion(image: photo)
            }
            
            
            return nil
        })
    }
    
    func uploadUserPhoto() {
        
        guard let photo     = User.sharedInstance.userImage else {return}
        let photoKey        = kUserPhotoKeyPrefix + "\(User.sharedInstance.userUniqueID)" + ".jpg"
        let uploadFilePath  = NSTemporaryDirectory().stringByAppendingString(photoKey)
        let uploadFileURL   = NSURL.fileURLWithPath(uploadFilePath)

        
        UIImageJPEGRepresentation(photo,1)!.writeToURL(uploadFileURL, atomically: true)
        
        // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
        // the more it's compressed the smaller the file is
        
        let uploadRequest       = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket    = self.bucketNameForBundle() //"foodcollector"
        uploadRequest.key       = photoKey
        uploadRequest.body      = uploadFileURL
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task: AWSTask!) -> AnyObject! in
            
            if task.error != nil {
                
                //   print("task error: \(task.error)")
            }
            
            if task.result != nil {
                
                //    print("success: \(task.result)")
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
        var infoPlist   : NSDictionary?
        var baseURLPlist: NSDictionary?
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType:"plist") {
            
            infoPlist = NSDictionary(contentsOfFile: path)
        }
        
        if let path = NSBundle.mainBundle().pathForResource("BaseURL", ofType:"plist") {
            
            baseURLPlist = NSDictionary(contentsOfFile: path)
        }
        
        
        
        if let infoPlist = infoPlist {
            
            let bundleName = infoPlist["CFBundleName"] as! String
            let serverUrl  = baseURLPlist?["Server URL"] as? String
            
            print("bundle: \(bundleName)")
            print("server: \(serverUrl)")
            
            //GERMANY
            if bundleName == "FoodonetEU" {
                
                //TODO: Change bucket name german bucket
                print("EU Version. bucket is \(self.foodCollectorDevelopmentBucketName)")
                return self.foodCollectorDevelopmentBucketName
                
            }
                
                //DEV
            else if serverUrl == "https://prv-fd-server.herokuapp.com/" ||
                    serverUrl == "https://ofer-prv-fd-server.herokuapp.com/"{
                
                print("dev Version. user photoes buck is \(self.foodCollectorDevelopmentBucketName)")
                return self.foodCollectorDevelopmentBucketName
                
            }
        }
        
        print("prod or beta - user photoes bucket is \(self.foodCollectorProductionBucketName)")
        return self.foodCollectorProductionBucketName
    }
}
