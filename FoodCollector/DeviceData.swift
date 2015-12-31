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
        // Check if fileName has a .plist suffix. If it has, remove it.
        var fileNameExtention = ""
        fileNameExtention = (fileName as NSString).pathExtension
        if (fileNameExtention != "") {
            fileNameExtention = "." + fileNameExtention
            fileName = (fileName as NSString).stringByDeletingPathExtension
        }
        else {
            fileNameExtention = ".plist"
        }
        
        // Check if resource exists. If not, return nil.
        if let plistFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileNameExtention) {
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
        fileName = "\\" + fileName
        
        if FCModel.documentsDirectory() == "" {
            return false
        }
        let path = FCModel.documentsDirectory().stringByAppendingString(fileName)
        
        // Check what type of data we got (NSArray or NSDIctionary
        
        switch data {
        case is NSArray:
            (data as! NSArray).writeToFile(fileName, atomically: true)
        case is NSDictionary:
            (data as! NSDictionary).writeToFile(fileName, atomically: true)
        default:
            return false
        }
        print("Saved plist file in --> \(path)")
        
        return true
    }
}
