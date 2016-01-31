#!/usr/bin/env xcrun swift -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
//#!/usr/bin/swift
//  EUPreBuildScript.swift
//  FoodCollector
//
//  Created by Guy Freedman on 30/01/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation


let filemgr = NSFileManager.defaultManager()
let projectPath = filemgr.currentDirectoryPath



// BaseURL.plist dictionary values, key and path
let kLocalHostURLVal = "http://localhost:3000/"
let kProdURLVal      = "https://fd-server.herokuapp.com/"
let kDevURLVal       = "https://prv-fd-server.herokuapp.com/"
let kBetaURLVal      = "https://fd-server.herokuapp.com/"
let kDictKey         = "Server URL"


let pathToBaseURLPlist = projectPath + "/FoodCollector/BaseURL.plist"
var plistDict = NSMutableDictionary(contentsOfFile: pathToBaseURLPlist)
plistDict?.setObject(kDevURLVal,  forKey: kDictKey)
plistDict?.writeToFile(pathToBaseURLPlist, atomically: false)

