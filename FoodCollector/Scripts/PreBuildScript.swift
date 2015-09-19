#!/usr/bin/env xcrun swift -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
//
//  PreBuildScript.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 18/02/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

// chmod +rx       adds read and execute for everyone
import Foundation

print(">>>> Start Script")

let filemgr = NSFileManager.defaultManager()
let projectPath = filemgr.currentDirectoryPath


//println(${SRCROOT})
// BaseURL.plist dictionary values, key and path
let kProdURLVal = "https://fd-server.herokuapp.com/"
let kDevURLVal  = "https://prv-fd-server.herokuapp.com/"
let kBetaURLVal = "https://fd-server.herokuapp.com/"
let kDictKey    = "Server URL"
let pathToBaseURLPlist = projectPath + "/FoodCollector/BaseURL.plist"
// "/Users/Guy/ios projects/foodCollector4/FoodCollector/FoodCollector/Info.plist"


// Info.plist dictionary values, keys and path
let kBundleIDKey          = "CFBundleIdentifier"
let kBundleIDProdVal      = "com.gogalefree.$(PRODUCT_NAME:rfc1034identifier)"
let kBundleIDDevVal       = "com.gogalefree.$(PRODUCT_NAME:rfc1034identifier).dev"
let kBundleIDBetaVal      = "com.gogalefree.$(PRODUCT_NAME:rfc1034identifier).beta"
let kBundleNameKey        = "CFBundleName"
let kBundleNameProdVal    = "$(PRODUCT_NAME)"
let kBundleNameDevVal     = "dev.$(PRODUCT_NAME)" 
let kBundleNameBetaVal    = "beta.$(PRODUCT_NAME)"
let kBundleDispNameKey    = "CFBundleDisplayName"
let kBundleDispNameDevVal = "FDN Dev"
let kBundleDispNameBetaVal = "FDN Beta"
let kBundleDispNameProdVal = "Foodonet"

let pathToInfoPlist = projectPath + "/FoodCollector/Info.plist"
//"/Users/Guy/ios projects/foodCollector4/FoodCollector/FoodCollector/BaseURL.plist"

let args = Process.arguments
var argValue = "dev"
if args.count > 1 {
    argValue = args[1]
}

print(argValue)

// START Changes to BaseURL.plist
var plistDict = NSMutableDictionary(contentsOfFile: pathToBaseURLPlist)
print("before changing \(plistDict)")

// Change BaseURL.plist dictionary values based on argument value
switch argValue {
case "prod": // Production URL
    plistDict!.setObject(kProdURLVal, forKey: kDictKey)
case "beta": // Beta URL
    plistDict!.setObject(kBetaURLVal, forKey: kDictKey)
default: // Dev URL
    plistDict!.setObject(kDevURLVal,  forKey: kDictKey)
}

print("after changing \(plistDict)")

plistDict!.writeToFile(pathToBaseURLPlist, atomically: false)

// END Changes to BaseURL.plist

// START Changes to Info.plist
plistDict = NSMutableDictionary(contentsOfFile: pathToInfoPlist)
print("before changing \(plistDict)")
print("arg value \(argValue)")

// Change Info.plist dictionary values based on argument value
switch argValue {
case "prod": // Production URL
    plistDict!.setObject(kBundleIDProdVal,         forKey: kBundleIDKey)
    plistDict!.setObject(kBundleNameProdVal,       forKey: kBundleNameKey)
    plistDict!.setObject(kBundleDispNameProdVal,    forKey: kBundleDispNameKey)

case "beta": // Beta URL
    plistDict!.setObject(kBundleIDBetaVal,         forKey: kBundleIDKey)
    plistDict!.setObject(kBundleNameBetaVal,       forKey: kBundleNameKey)
    plistDict!.setObject(kBundleDispNameBetaVal,    forKey: kBundleDispNameKey)

default: // Dev URL
    plistDict!.setObject(kBundleIDDevVal,          forKey: kBundleIDKey)
    plistDict!.setObject(kBundleNameDevVal,        forKey: kBundleNameKey)
    plistDict!.setObject(kBundleDispNameDevVal,    forKey: kBundleDispNameKey)
}
print("after changing \(plistDict)")
print("arg value \(argValue)")


if plistDict!.writeToFile(pathToInfoPlist, atomically: true) {

    print("path saved: \(pathToInfoPlist)")
    print("plist saved")
}

// End Changes to Info.plist

print(">>>> End Script")


