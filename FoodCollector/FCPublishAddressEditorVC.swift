//
//  FCPublishAddressEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 01/01/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit
import MapKit

class FCPublishAddressEditorVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
//    var dataSource = [FCNewPublicationTVCCellData]()
//    var selectedDataObj : FCNewPublicationTVCCellData?
    var selectedTagNumber = 0
    var didSerchAndFindResults = false
    var initialData = [String]()
    var selectedAddress = ""
    var selectedLatitude = 0.0
    var selectedLongtitude = 0.0
    var selectedCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0,0.0)
    
//    let pre1 = "רחוב "
//    let pre2 = "רח "
//    let pre3 = "רח׳ "
//    let pre4 = "רחו"
    
    
    //var prefixes = [String]()


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
 //       selectedDataObj = getSelectedDataObject(selectedTagNumber)
        //prefixes = [pre1, pre2, pre3, pre4]
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !didSerchAndFindResults {return 0}
        println("return initialData.count: \(initialData.count)")
        return initialData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("start cell defenition")

        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = self.initialData[indexPath.row] as String
        println("cell text has been set")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        if cell.textLabel?.text != nil {
            var address = cell.textLabel?.text!
            self.googleReverseGeoCodeForAddress(address!)
            searchBar.text = address
            selectedAddress = address!
            selectedCoordinate = CLLocationCoordinate2DMake(selectedLatitude, selectedLongtitude)
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
            if !self.didSerchAndFindResults {
                println("self.googleLocationSearch(\(searchText))")
                self.googleLocationSearch(searchText)
                
            }
            else {
                println("self.refineSearchResults(\(searchText))")
                self.refineSearchResults(searchText)
                // Currently not implemented
                
            }
        }
    }
    
    func googleLocationSearch(searchText: String) {
        
        var key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        var input = searchText
        input = input.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&key=\(key)")!)
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            
            if (error == nil) {
                println("response: \(response)")
                
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                println("result: \(jsonResult) " )
                
                
                var arrayOfPredications = jsonResult["predictions"] as NSArray
                
                if arrayOfPredications.count != 0 {
                    
                    self.didSerchAndFindResults = true
                    
                    for object in arrayOfPredications {
                        var dict = object as NSDictionary
                        var desc = dict["description"] as String
                        println(desc)
                        self.initialData.append(desc)
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }else {
                //handle error
                println(error.description)
            }
            
            
            
        }).resume()
    }
    
    func googleReverseGeoCodeForAddress(address: String) {
        
        let key = "AIzaSyBo3ImqNe1wOkq3r3z4S9YRVp3SIlaXlJY"
        let addressToSearch = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        let request = NSURLRequest(URL: NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(addressToSearch)&key=\(key)")!)
        
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if error == nil {
                
                //println("response: \(response)")
                
                let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                //println("result: \(jsonResult) " )
                
                
                let results = jsonResult["results"] as NSArray
                let aResultDict = results.lastObject as NSDictionary
                let geo = aResultDict["geometry"] as NSDictionary
                let locationDict = geo["location"] as NSDictionary
                self.selectedLatitude = locationDict["lat"] as Double
                self.selectedLongtitude = locationDict["lng"] as Double
                //println("dict is \(latitude) and \(longtitude)")
                
            }else {
                //handle error
                println(error.description)
            }
            
        }).resume()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.didSerchAndFindResults = false
        self.initialData.removeAll(keepCapacity: false)
        self.googleLocationSearch(searchBar.text)
        self.tableView.reloadData()
    }
    
    func refineSearchResults(searchText: String) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    private func getSelectedDataObject(selectedTagNumber:Int) -> FCNewPublicationTVCCellData {
//        return dataSource[selectedTagNumber]
//    }
//
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
