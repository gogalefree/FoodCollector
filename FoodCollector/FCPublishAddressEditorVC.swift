//
//  FCPublishAddressEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 01/01/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import CoreLocation




class FCPublishAddressEditorVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let addressEditorTitle = NSLocalizedString("Select Address", comment:"the editor title for enter a publication address")
    let lastSearchesHeaderTitle = NSLocalizedString("Last searches", comment:"the section header title for last searches history list")
    let currentLocationText = NSLocalizedString("Current location", comment:"the string for current location table row")
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Address Search History
    let plistSearchHistoryFilneName = "/SearchHistory"
    let plistSearchHistoryFilneNameExt = "plist"
    var isThereSearchHistory = false
    var searchHistoryArray: [[String: AnyObject]] = [] //an array of dicionaries
    let maxItemsToDisplay = 8 // The maximum number of items to display in the search history list
    
    var didStartedSearch = false
    
    var addressDict: [String: AnyObject]?
    var cellData = PublicationEditorTVCCellData()
    var didSerchAndFindResults = false
    var initialData = [String]()
    var selectedAddress = ""
    var selectedLatitude = 0.0
    var selectedLongtitude = 0.0
    var googleLanguageCode = "en"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = addressEditorTitle
        
        self.tableView.registerNib(UINib(nibName: "FCPublishAddressEditorMyLocationCustomCell", bundle: nil), forCellReuseIdentifier: "myLocationCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "FCPublishAddressEditorAddressHistoryCustomCell", bundle: nil), forCellReuseIdentifier: "addressHistoryCustomCell")

        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        
        // Check if theres a search history and If true, load the conteמt of the serach History
        readArrayResultsFromPlist(plistSearchHistoryFilneName, fileExt: plistSearchHistoryFilneNameExt)
        
        if (isThereSearchHistory){
            loadContentOfSearchHistory()
            self.tableView.reloadData()
        }
        
        setGoogleCountryCode()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (isThereSearchHistory){
            return 2
        }
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (section == 0 && !didStartedSearch){
            return 1
        }
        return initialData.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 1 && !didStartedSearch){
            let headerView = FCPublishAddressEditorAddressHistoryCustomHeaderView.instanceFromNib()
            return headerView
        }
        
        
        return nil
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1 && !didStartedSearch){
            return 30.0
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0 && !didStartedSearch) {
            let myLocationCell = tableView.dequeueReusableCellWithIdentifier("myLocationCustomCell", forIndexPath: indexPath) as! FCPublishAddressEditorMyLocationCustomCell
            
            return myLocationCell
        }
        else {
            let searchHistoryCell = tableView.dequeueReusableCellWithIdentifier("addressHistoryCustomCell", forIndexPath: indexPath) as! FCPublishAddressEditorAddressHistoryCustomCell
            
            searchHistoryCell.addressName.text! = self.initialData[indexPath.row] as String
            return searchHistoryCell
        }        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        
        // if first row (in first section) was selected (Use my currnt loction) use the reverse geocoder
        if (indexPath.item == 0 && indexPath.section == 0 && !didSerchAndFindResults){
            self.selectedLatitude = FCModel.sharedInstance.userLocation.coordinate.latitude
            self.selectedLongtitude = FCModel.sharedInstance.userLocation.coordinate.longitude
            self.googleReverseGeoCodeForLatLngLocation(lat: self.selectedLatitude, lon: self.selectedLongtitude)
        }
        else {
            let userSelectedAddress = self.initialData[indexPath.item] as String
            self.googleGeoCodeForAddress(userSelectedAddress)
            searchBar.text = userSelectedAddress
            selectedAddress = userSelectedAddress

        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("didStartedSearch = true")
        didStartedSearch = true
        isThereSearchHistory = false // if we start a search, it's as if we do not have a serach history
        let newText = searchText as NSString
        
        if (newText.length < 6) {
            if (newText.length == 0) {
                self.initialData.removeAll(keepCapacity: false)
                print("THE SEARCH BAR IS EMPTY")
                self.didStartedSearch = false
                readArrayResultsFromPlist(plistSearchHistoryFilneName, fileExt: plistSearchHistoryFilneNameExt)
                
                if (isThereSearchHistory){
                    loadContentOfSearchHistory()
                    self.tableView.reloadData()
                }
            }
            print("if newText.length < 6 \(newText.length)")
            self.didSerchAndFindResults = false
            if (newText.length > 0){self.initialData.removeAll(keepCapacity: false)}
            self.tableView.reloadData()
            return
        }
        else {
            print("else \(newText.length)")
            print("self.googleLocationSearch(\(searchText))")
            self.googleLocationSearch(searchText)
        }
    }
    
    func googleLocationSearch(searchText: String) {
        
        let key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        var input = searchText
        input = input.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&key=\(key)")!)
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            
            if response != nil {
                
                if (error == nil) {
                    
                    if let data = data {
                        let jsonResult = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
                        
                        print("result: \(jsonResult) " )
                        
                        if let jsonResult = jsonResult {
                            
                            
                            let arrayOfPredications = jsonResult["predictions"] as! NSArray
                            
                            if arrayOfPredications.count != 0 {
                                
                                self.didSerchAndFindResults = true
                                self.initialData.removeAll(keepCapacity: false)
                                
                                for object in arrayOfPredications {
                                    let dict = object as! NSDictionary
                                    let desc = dict["description"] as! String
                                    print(desc)
                                    self.initialData.append(desc)
                                }
                                
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                }else {
                    //handle error
                    print(error!.description)
                }
            }
            else {
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(kCommunicationIssueTitle, aMessage: kCommunicationIssueBody)
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                
            }
            
            
            
            
        }).resume()
    }
    
    func googleGeoCodeForAddress(address: String) {
        
        let key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        let addressToSearch = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(addressToSearch)&key=\(key)")!)
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if response != nil {
                
                if error == nil {
                    
                    if let data = data {
                        let jsonResult = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
                        
                        if let jsonResult = jsonResult {
                            let results = jsonResult["results"] as! NSArray
                            let aResultDict = results.lastObject as! NSDictionary
                            let geo = aResultDict["geometry"] as! NSDictionary
                            let locationDict = geo["location"] as! NSDictionary
                            self.selectedLatitude = locationDict["lat"] as! Double
                            self.selectedLongtitude = locationDict["lng"] as! Double
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.performSegueWithIdentifier("unwindFromAddressEditorVC", sender: self)
                            })
                        }
                    }
                }
                else {
                    //handle error
                    print(error!.description)
                    // UIALERT
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(NSLocalizedString("An error accord", comment:"An error accord"), aMessage: kCommunicationIssueBody)
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                // UIALERT
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(kCommunicationIssueTitle, aMessage: kCommunicationIssueBody)
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            }
            
        }).resume()
    }
    
    func googleReverseGeoCodeForLatLngLocation(lat lat: Double, lon: Double) {
        let key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        //https://maps.googleapis.com/maps/api/geocode/json?latlng=32.1499984,34.8939178&language=iw&key=API_KEY
        //print("https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lon)&language=\(googleLanguageCode)&key=\(key)")
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lon)&language=\(googleLanguageCode)&key=\(key)")!)
        
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let response = response {
                
                print("response: \(response)")
                
                if error == nil {
                    
                    if data != nil {
                        
                        let jsonResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
                        
                        if let jsonResult = jsonResult {
                    
                            print("data: \(data)")

                        
                            let jResults = jsonResult["results"] as? NSArray
                            
                            let addrResultDict = jResults?.firstObject as? NSDictionary
                            if let address = addrResultDict?.valueForKey("formatted_address") as? String {
                                self.selectedAddress = address
                            }
                            if addrResultDict != nil {
                                // Boris: Ask Guy what's this code for? Maybe, the 'let' needs to be removed?
                                //let geometryResults = addrResultDict?["geometry"] as! NSDictionary
                                //let locationDict = geometryResults["location"] as! NSDictionary
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.performSegueWithIdentifier("unwindFromAddressEditorVC", sender: self)
                                })
                            }
                        }
                    }
                }
                else {
                    //handle error
                    print(error!.description)
                    // UIALERT
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(NSLocalizedString("An error accord", comment:"An error accord"), aMessage: kCommunicationIssueBody)
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                // UIALERT
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton(kCommunicationIssueTitle, aMessage: kCommunicationIssueBody)
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            }
            
        }).resume()
    }
    
    func setGoogleCountryCode() {
        let userLocation = FCModel.sharedInstance.userLocation
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(userLocation, completionHandler: {(clPlacemarks, error)->Void in

            // The type Optional is an enumeration with two cases, None and Some(T), which are used to represent values that may or may not be present.
            //So under the hood an optional type looks like this:
            //enum Optional<T> {
            //    case None
            //    case Some(T)
            //}
            if let placemarks = clPlacemarks {
                if error == nil {
                    let placemark = placemarks[0] as CLPlacemark
                    switch placemark.ISOcountryCode {
                    case .Some("IL"): // Israel
                        self.googleLanguageCode = "iw" // Hebrew
                    case .Some("DE"): // Germany (Deutschland)
                        self.googleLanguageCode = "de" // German (Deutsch)
                    case .None:
                        self.googleLanguageCode = "en" // English
                    default:
                        self.googleLanguageCode = "en" // English
                    }
                }
            }
        })
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //remove country from string
        var sub = self.selectedAddress.substringFromIndex(selectedAddress.endIndex.advancedBy(-7))
        print("sub: \(sub)")
        if sub == ", ישראל" {
            self.selectedAddress = selectedAddress.substringToIndex(selectedAddress.endIndex.advancedBy(-7))
            print("\(selectedAddress)")
        }
        
        sub = self.selectedAddress.substringFromIndex(selectedAddress.endIndex.advancedBy(-8))
        if sub == ", Israel" {
            self.selectedAddress = selectedAddress.substringToIndex(selectedAddress.endIndex.advancedBy(-8))
            print("\(selectedAddress)")
        }
        
        let addressDict: [String: AnyObject] = ["adress":self.selectedAddress ,"Latitude":self.selectedLatitude, "longitude" : self.selectedLongtitude]
        
        cellData.userData = addressDict
        cellData.containsUserData = true
        cellData.cellTitle = self.selectedAddress
        
        // Add Address data to serach History Array Object and write it to a plist
        print(addressDict.description)
        appendAddressToSerachHistoryArray(addressDict)
        writeArrayResultsToPlist(plistSearchHistoryFilneName,fileExt: plistSearchHistoryFilneNameExt)
    }
    
    // MARK - Address Search History
    
    func readArrayResultsFromPlist(fileName: String, fileExt: String){

        
        let fullPlistName = fileName + "." + fileExt
        let publicationsFilePath = FCModel.documentsDirectory().stringByAppendingString(fullPlistName)
        
        
        if NSFileManager.defaultManager().fileExistsAtPath(publicationsFilePath){
            isThereSearchHistory = true
            searchHistoryArray = NSArray(contentsOfFile: publicationsFilePath) as! [[String : AnyObject]]
            print(searchHistoryArray.description)
        }
        else {
            isThereSearchHistory = false
        }
    }
    
    func writeArrayResultsToPlist(fileName: String, fileExt: String){
        let fullPlistName = fileName + "." + fileExt
        let direcoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = direcoryPath.stringByAppendingString(fullPlistName)
        
        (searchHistoryArray as NSArray).writeToFile(path, atomically: true)
        
        print("Saved plist file in --> \(path)")
    }
    
    func loadContentOfSearchHistory(){
        var countItemsAdded = 0
        for serachItem in searchHistoryArray{
            let addr = (serachItem as NSDictionary).objectForKey("adress") as! String
            self.initialData.append(addr)
            countItemsAdded++
            if (countItemsAdded == maxItemsToDisplay) {break}
        }
    }
    
    func appendAddressToSerachHistoryArray(addrDict: [String : AnyObject]){
        print(addrDict.description)
        // Check if the address is already in History
        var isSearchAddressTheSame = true
        
        if (searchHistoryArray.count == 0){isSearchAddressTheSame = false}
        for serachItem in searchHistoryArray{
            let historyAddr = (serachItem as NSDictionary).objectForKey("adress") as! String
            let selectedAddr = (addrDict as NSDictionary).objectForKey("adress") as! String
            
            if historyAddr == selectedAddr {
                isSearchAddressTheSame = true
                break
            }
            else {
                isSearchAddressTheSame = false
            }
        }
        // Add the new Item at the begining of the array.
        // This way the last item, searched will be the first item at the top of the list.
        if (!isSearchAddressTheSame){searchHistoryArray.insert(addrDict, atIndex: 0)}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
