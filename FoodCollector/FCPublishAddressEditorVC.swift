//
//  FCPublishAddressEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 01/01/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import MapKit

let addressEditorTitle = String.localizedStringWithFormat( "הוספת כתובת", "the editor title for enter a publication address")

class FCPublishAddressEditorVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Address Search History
    let plistSearchHistoryFilneName = "SearchHistory"
    let plistSearchHistoryFilneNameExt = "plist"
    var isThereSearchHistory = false
    var searchHistoryArray: [[String: AnyObject]] = [] //an array of dicionaries
    let maxItemsToDisplay = 8 // The maximum number of items to display from the search history
    
    var addressDict: [String: AnyObject]?
    var cellData = FCPublicationEditorTVCCellData()
    var didSerchAndFindResults = false
    var initialData = [String]()
    var selectedAddress = ""
    var selectedLatitude = 0.0
    var selectedLongtitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = addressEditorTitle
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        
        // Check if theres a search history and If true, load the contect of the serach History
        readArrayResultsFromPlist(plistSearchHistoryFilneName, fileExt: plistSearchHistoryFilneNameExt)
        if (isThereSearchHistory){
            loadContentOfSearchHistory()
            self.tableView.reloadData()
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isThereSearchHistory){
            return initialData.count
        }
        else if !didSerchAndFindResults {
            return 0
        }
        println("return initialData.count: \(initialData.count)")
        return initialData.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("start cell defenition")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel?.text = self.initialData[indexPath.row] as String
        println("cell text has been set")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        if cell.textLabel?.text != nil {
            var address = cell.textLabel?.text!
            self.googleReverseGeoCodeForAddress(address!)
            searchBar.text = address
            selectedAddress = address!
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var newText = searchText as NSString
        
        if newText.length < 6 {
            println("if newText.length < 6 \(newText.length)")
            self.didSerchAndFindResults = false
            self.initialData.removeAll(keepCapacity: false)
            self.tableView.reloadData()
            return
        }
            
        else {
            println("else \(newText.length)")
            //if !self.didSerchAndFindResults {
            println("self.googleLocationSearch(\(searchText))")
            self.googleLocationSearch(searchText)
            
            /*}
            else {
            println("self.refineSearchResults(\(searchText))")
            self.refineSearchResults(searchText)
            // Currently not implemented
            
            }*/
        }
    }
    
    func googleLocationSearch(searchText: String) {
        
        var key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        var input = searchText
        input = input.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&key=\(key)")!)
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            
            if let respone = response {
             
                if (error == nil) {

                    if let data = data {
                    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)as! NSDictionary
                    
                    println("result: \(jsonResult) " )
                    
                    
                    var arrayOfPredications = jsonResult["predictions"] as! NSArray
                    
                    if arrayOfPredications.count != 0 {
                        
                        self.didSerchAndFindResults = true
                        self.initialData.removeAll(keepCapacity: false)
                        
                        for object in arrayOfPredications {
                            var dict = object as! NSDictionary
                            var desc = dict["description"] as! String
                            println(desc)
                            self.initialData.append(desc)
                        }
                        
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                    }
                    }
                }else {
                    //handle error
                    println(error.description)
                }
            }
            else {
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("בעיית רשת", aMessage: "נסו שנית")
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            
            }
            
            
            
            
        }).resume()
    }
    
    func googleReverseGeoCodeForAddress(address: String) {
        
        let key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        let addressToSearch = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(addressToSearch)&key=\(key)")!)
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if let response = response {
                
                if error == nil {
                    
                    //println("response: \(response)")
                    
                    let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                    
                    //println("result: \(jsonResult) " )
                    
                    
                    let results = jsonResult["results"] as! NSArray
                    let aResultDict = results.lastObject as! NSDictionary
                    let geo = aResultDict["geometry"] as! NSDictionary
                    let locationDict = geo["location"] as! NSDictionary
                    self.selectedLatitude = locationDict["lat"] as! Double
                    self.selectedLongtitude = locationDict["lng"] as! Double
                    //println("dict is \(latitude) and \(longtitude)")
                    
                }else {
                    //handle error
                    println(error.description)
                }

                
                
            }
            else {
                
            }
            
            
        }).resume()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.didSerchAndFindResults = false
        self.initialData.removeAll(keepCapacity: false)
        self.googleLocationSearch(searchBar.text)
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //remove country from string
        var sub = self.selectedAddress.substringFromIndex(advance(selectedAddress.endIndex, -7))
        if sub == ", ישראל" {
            self.selectedAddress = selectedAddress.substringToIndex(advance(selectedAddress.endIndex, -7))
            println("\(selectedAddress)")
        }
        
        sub = self.selectedAddress.substringFromIndex(advance(selectedAddress.endIndex, -8))
        if sub == ", Israel" {
            self.selectedAddress = selectedAddress.substringToIndex(advance(selectedAddress.endIndex, -8))
            println("\(selectedAddress)")
        }
        
        var addressDict: [String: AnyObject] = ["adress":self.selectedAddress ,"Latitude":self.selectedLatitude, "longitude" : self.selectedLongtitude]
        
        cellData.userData = addressDict
        cellData.containsUserData = true
        cellData.cellTitle = self.selectedAddress
        
        // Add Address data to serach History Array Object and write it to a plist
        appendAddressToSerachHistoryArray(addressDict)
        writeArrayResultsToPlist(plistSearchHistoryFilneName,fileExt: plistSearchHistoryFilneNameExt)
    }
    
    
    /*
    func refineSearchResults(searchText: String) {
    
    }
    */
    
    // MARK - Address Search History
    
    func readArrayResultsFromPlist(fileName: String, fileExt: String){
        println("// Check for Search History")
        println("======================================")
        
        var fullPlistName = fileName + "." + fileExt
        let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingPathComponent(fullPlistName)
        
        println("Path: \(publicationsFilePath)")
        
        if NSFileManager.defaultManager().fileExistsAtPath(publicationsFilePath){
            isThereSearchHistory = true
            searchHistoryArray = NSArray(contentsOfFile: publicationsFilePath) as! [[String : AnyObject]]
            
            
            //println("Path: \(path)")
            println(searchHistoryArray.description)
        }
        else {
            println("Could not load \(fileName).\(fileExt)")
            isThereSearchHistory = false
        }
        println("isThereSearchHistory: \(isThereSearchHistory)")
    }
    
    func writeArrayResultsToPlist(fileName: String, fileExt: String){
        var fullPlistName = fileName + "." + fileExt
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var path = paths.stringByAppendingPathComponent(fullPlistName)
        
        (searchHistoryArray as NSArray).writeToFile(path, atomically: true)
        
        println("Saved plist file in --> \(path)")
    }
    
    func loadContentOfSearchHistory(){
        var countItemsAdded = 0
        for serachItem in searchHistoryArray{
            var addr = (serachItem as NSDictionary).objectForKey("adress") as! String
            self.initialData.append(addr)
            countItemsAdded++
            if (countItemsAdded == maxItemsToDisplay) {break}
        }
    }
    
    func appendAddressToSerachHistoryArray(addrDict: [String : AnyObject]){
        // Check if the address is already in History
        var isSearchAddressTheSame = true
        for serachItem in searchHistoryArray{
            var historyAddr = (serachItem as NSDictionary).objectForKey("adress") as! String
            var selectedAddr = (addrDict as NSDictionary).objectForKey("adress") as! String
            
            if historyAddr == selectedAddr {
                isSearchAddressTheSame = true
                break
            }
            else {
                isSearchAddressTheSame = false
            }
        }
        // Add the new Item at the begining of the array.
        // This way the last ite, searched will be the first item at the top of the list.
        if (!isSearchAddressTheSame){searchHistoryArray.insert(addrDict, atIndex: 0)}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
