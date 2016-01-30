//
//  DeviceData.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 28.12.2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

/// responsible of getting device data and read/write local data

public enum PlistDataType {
    case Array, Dictionary, None
}

public class DeviceData {
    
    // Singleton
    static let sharedInstance = DeviceData()
    
    // DeviceData property values
    
    // 'private' prevents other classes from using the default '()' initializer for this class.
    private init() {
    }
    
    
    
    class func screenWidth() -> CGFloat {
        return UIScreen.mainScreen().bounds.width
    }
    
    class func screenHight() -> CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
    
}

// MARK: Read & Write plist

public extension DeviceData {
    
    public class func readPlist(var fileName: String) -> (data: AnyObject?, dataType: PlistDataType){
        // Check if fileName has a pathExtension. If it doesn't, add it.
        if ((fileName as NSString).pathExtension == "") {
            fileName = fileName + ".plist"
        }
        
        fileName = "/" + fileName
        print("filename: \(fileName)")
        if FCModel.documentsDirectory() != "" {
            let plistFilePath = FCModel.documentsDirectory().stringByAppendingString(fileName)
            print("plistFilePath: \(plistFilePath)")
            let plistData = NSDictionary(contentsOfFile: plistFilePath)
            // If plistData == nil it's not a dictionary - It's an array
            if plistData == nil {
                let plistData = NSArray(contentsOfFile: plistFilePath)
                return (plistData, .Array)
            }
            else {
                return (plistData, .Dictionary)
            }
        }
        else {
            return (nil, .None)
        }
    }
    
    public class func writePlist(var fileName: String, data: AnyObject) -> Bool {
        // Check if fileName has a .plist suffix. If it has, remove it.
        let fileNameExtention = "plist"
        if (fileNameExtention != (fileName as NSString).pathExtension) {
            fileName = fileName + "." + fileNameExtention
        }
        fileName = "/" + fileName
        
        if FCModel.documentsDirectory() == "" {
            return false
        }
        let path = FCModel.documentsDirectory().stringByAppendingString(fileName)
        
        // Check what type of data we got (NSArray or NSDIctionary
        
        switch data {
        case is NSArray:
            (data as! NSArray).writeToFile(path, atomically: true)
        case is NSDictionary:
            (data as! NSDictionary).writeToFile(path, atomically: true)
        default:
            return false
        }
        print("Saved plist file in --> \(path)")
        
        return true
    }
    
    public class func writeImage(image: UIImage, imageName: String) -> Bool {
        print("writeImage")
        print("imageName: \(imageName)")
        print("image:\n\(image)")
        
        do {
            let fileManager = NSFileManager.defaultManager()
            let documentsURL = try fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            let imageURL = documentsURL.URLByAppendingPathComponent(imageName)
            
            print("documentsURL: \(documentsURL)")
            
            if (!UIImageJPEGRepresentation(image,1)!.writeToURL(imageURL, atomically: true)){
                print("Image was NOT writen to URL!!!")
                return false
            }
        } catch {
            print(error)
            return false
        }
        
        return true
    }
}
