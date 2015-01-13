//
//  FCPublicationEditorTVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//


import Foundation
import UIKit
import CoreLocation

// String constants for Publish table titles
let kPublishTitle = String.localizedStringWithFormat("Add title", "Add title for a new event")
let kPublishSubtitle = String.localizedStringWithFormat("Add subtitle", "Add subitle for a new event")
let kPublishAddress = String.localizedStringWithFormat("Add address", "Add address for a new event")
let kPublishTypeOfCollection = String.localizedStringWithFormat("Select type of collection", "Select Type Of Collection for a new event")
let kPublishTypeOfCollectionFreePickUp = String.localizedStringWithFormat("Collection type: Free pickup", "Select Type Of Collection for a new event: Free pickup")
let kPublishTypeOfCollectionContactPublisher = String.localizedStringWithFormat("Collection type: Contact publisher", "Type Of Collection for a new event: Contact publisher")
let kPublishStartDate = String.localizedStringWithFormat("Add start date", "Add start date for a new event")
let kPublishStartDatePrefix = String.localizedStringWithFormat("Start:\t", "Start date label for displaying an exciting start date event")
let kPublishEndDate = String.localizedStringWithFormat("Add end date", "Add ebd date for a new event")
let kPublishEndDatePrefix = String.localizedStringWithFormat("End:\t", "End date label for displaying an exciting end date event")
let kPublishContactPhoneNumber = String.localizedStringWithFormat("Add phone number", "Add phone number for a new event")
let kPublishContactPhoneNumberPrefix = String.localizedStringWithFormat("Phone number: ", "Phone number label for displaying an exciting phone number")
let kPublishImage = String.localizedStringWithFormat("Add image", "Add image for a new event")
let kPublishTakeOffAirButtonLabel = String.localizedStringWithFormat("Take Off Air", "Take Off Air button to immediately stop publication of an exciting active event")
let kPublishPublishButtonLabel = String.localizedStringWithFormat("Publish", "Publish button to publish a new event")

let kCellHeight = CGFloat(50.0)
let kSeperatorHeight = CGFloat(30.0)
let kImageCellHeight = CGFloat(140.0)


/// represents the cell data of the editor.

struct FCNewPublicationTVCCellData {
    
    var height:CGFloat = kCellHeight
    var containsUserData:Bool = false // Check if there's data for this cell. if not display default title
    var cellText:String = ""
    var isObligatory:Bool = false // Check if we can publish (All data is entered by user)
    var userData:AnyObject = ""
    var addressLatitude = 0.0
    var addressLongtitude = 0.0
    // For address userData -> need to be tuple (address:String, coordinate:CLLocationCoordinate2D)
    //var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
    var isSeperator:Bool = false
    var isTakeOffAirBuuton:Bool = false
    var isPublishButton:Bool = false
    var isImgCell:Bool = false
    var identityTag:Int = 0
    
    
}

enum FCPublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
    
}

public enum FCTypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}

class FCPublicationEditorTVC : UITableViewController, FCPublicationDataInputDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var publication:FCPublication?
    var dataSource = [FCNewPublicationTVCCellData]()
    var identityTagCounter = 0
    var isNewPublication = true
    var imgURL = ""
    var isReadyForTakeOffAir = false
    var isReadyForPublish = false
    var isImageInPublication = false
    var numberOfCells = 0
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    
    
    @IBAction func unwindFromStringFieldsEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishStringFieldsEditorVC
        if sourceVC.showTextField {
            updateDataSource(sourceVC.pubTitleText.text, selectedTagNumber: sourceVC.selectedTagNumber)
        }
        else {
            updateDataSource(sourceVC.pubSubTitleText.text, selectedTagNumber: sourceVC.selectedTagNumber)
        }
        //tableView.reloadData()
        reloadTableWithNewData()
    }
    
   
    @IBAction func unwindFromDateEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishDateEditorVC
        updateDataSource(sourceVC.datePicker.date, selectedTagNumber: sourceVC.selectedTagNumber)
        //tableView.reloadData()
        reloadTableWithNewData()
    }
    
    @IBAction func unwindFromTypeOfCollectionEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublicationTypeOfPublicationEditorVC
        updateDataSource(sourceVC.selectedValueInt, selectedTagNumber: sourceVC.selectedTagNumber)
        if sourceVC.selectedValueInt == 1 {
            // delete seperator and phone number from datasource (and therefore from table)
            removeFromDataSource(sourceVC.selectedTagNumber+1)
            removeFromDataSource(sourceVC.selectedTagNumber+1)
        }
        else {
            var cellData = FCNewPublicationTVCCellData()
            // For a Seperator
            
            cellData.height = kSeperatorHeight
            cellData.isSeperator = true
            cellData.isObligatory = true
            cellData.identityTag = sourceVC.selectedTagNumber+1
            insertIntoDataSource(cellData, index: sourceVC.selectedTagNumber+1)
            
            // For Contact Info
            cellData.height = kCellHeight
            cellData.isSeperator = false
            cellData.isObligatory = false
            cellData.cellText = kPublishContactPhoneNumber
            cellData.identityTag = sourceVC.selectedTagNumber+2
            insertIntoDataSource(cellData, index: sourceVC.selectedTagNumber+2)
            
        }
        numberOfCells = dataSource.count
        reloadTableWithNewData()
    }
    
    @IBAction func unwindFromAddressEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishAddressEditorVC
        //let aaddressInfo = (address:sourceVC.selectedAddress, coordinate:sourceVC.selectedCoordinate)
        let aaddressInfo:[String:AnyObject] = ["address": sourceVC.selectedAddress as String, "lat": sourceVC.selectedLatitude as Double, "lon":sourceVC.selectedLongtitude as Double]
        updateDataSource(aaddressInfo as NSDictionary, selectedTagNumber: sourceVC.selectedTagNumber)
        reloadTableWithNewData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if publication != nil {
            self.createCellDataForExistingPublication(publication!)
            //setIsReadyForTakeOffAir()
        }
        else {
            self.createCellDataForNewPublication()
        }
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        setIsReadyForTakeOffAir()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return kCellHeight
        }
        if dataSource[indexPath.row].isSeperator {
            return dataSource[indexPath.row].height
        }
        if dataSource[indexPath.row].isImgCell {
            return dataSource[indexPath.row].height
        }
        
        return dataSource[indexPath.row].height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCell {
        //println("Start: tableView: cellForRowAtIndexPath")
        let cellIdentifier = "publicationEditorTVCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        var adjustedIndex = getAdjustedIndexPath(indexPath.row)
        
        // Reset cell attributes
        cell.alpha = CGFloat(0.0)
        cell.backgroundColor = UIColor.whiteColor()
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.textLabel!.textAlignment = NSTextAlignment.Left
        cell.textLabel!.text = "" + "RESET I=\(indexPath.row) (\(adjustedIndex))"
        cell.userInteractionEnabled = true
        
        switch adjustedIndex {
        case 3,7,9: // Seperator
            cell.textLabel!.text = ""// + " I=\(indexPath.row) (\(adjustedIndex))"
            cell.userInteractionEnabled = false
            cell.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.00)
        case 10: // Image cell
            if isImageInPublication {
                cell.contentView.addSubview(getImage(indexPath.row, cellWidth: Double(cell.frame.width), cellHeight: Double(cell.frame.height)))
            }
            else {
                
                cell.textLabel!.text = dataSource[indexPath.row].cellText// + " I=\(indexPath.row) (\(adjustedIndex))"
            }
        case 11: // Take off-air cell
            cell.textLabel!.text = kPublishTakeOffAirButtonLabel //+ " I=\(indexPath.row) (\(adjustedIndex))"
            cell.textLabel!.textAlignment = NSTextAlignment.Center
            cell.textLabel!.textColor = UIColor.lightGrayColor()
            cell.userInteractionEnabled = false
            if isReadyForTakeOffAir {
                cell.textLabel!.textColor = UIColor.redColor()
                cell.userInteractionEnabled = true
            }
        case 12: // Publish cell
            cell.textLabel!.text = kPublishPublishButtonLabel// + " I=\(indexPath.row) (\(adjustedIndex))"
            cell.textLabel!.textAlignment = NSTextAlignment.Center
            cell.textLabel!.textColor = UIColor.lightGrayColor()
            cell.userInteractionEnabled = false
            if isReadyForPublish {
                cell.textLabel!.textColor = UIColor(red: 0.00, green: 0.36, blue: 0.99, alpha: 1.00)
                cell.userInteractionEnabled = true
            }
        default:
            cell.textLabel!.text = dataSource[indexPath.row].cellText// + " I=\(indexPath.row) (\(adjustedIndex))"
        }
        
        
        
        /*
        // Reset cell attributes
        cell.alpha = CGFloat(0.0)
        cell.textLabel!.text = "" + " I=\(indexPath.row)"
        cell.userInteractionEnabled = true
        if dataSource[indexPath.row].isSeperator {
        cell.textLabel!.text = "" + " I=\(indexPath.row)"
        cell.userInteractionEnabled = false
        cell.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.00)
        }
        else if dataSource[indexPath.row].isImgCell {
        if isImageInPublication {
        cell.textLabel!.text = "Image Goes Here" + " I=\(indexPath.row)"
        //cell.addSubview(getImage(indexPath.row, cellWidth: Double(cell.frame.width), cellHeight: Double(cell.frame.height)))
        }
        else {
        
        cell.textLabel!.text = dataSource[indexPath.row].cellText + " I=\(indexPath.row)"
        }
        }
        else if dataSource[indexPath.row].isTakeOffAirBuuton {
        cell.textLabel!.text = kPublishTakeOffAirButtonLabel + " I=\(indexPath.row)"
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.textLabel!.textColor = UIColor.lightGrayColor()
        cell.userInteractionEnabled = false
        if isReadyForTakeOffAir {
        cell.textLabel!.textColor = UIColor.redColor()
        cell.userInteractionEnabled = true
        }
        }
        else if dataSource[indexPath.row].isPublishButton {
        cell.textLabel!.text = kPublishPublishButtonLabel + " I=\(indexPath.row)"
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.textLabel!.textColor = UIColor.lightGrayColor()
        cell.userInteractionEnabled = false
        if isReadyForPublish {
        cell.textLabel!.textColor = UIColor(red: 0.00, green: 0.36, blue: 0.99, alpha: 1.00)
        cell.userInteractionEnabled = true
        }
        }
        else {
        cell.textLabel!.text = dataSource[indexPath.row].cellText + " I=\(indexPath.row)"
        }
        */
        
        cell.tag = dataSource[indexPath.row].identityTag
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Case No.: \(indexPath.row)")
        var adjustedIndex = getAdjustedIndexPath(indexPath.row)
        
        switch adjustedIndex {
        case 0, 1, 8: // Title, Subtutle & Phone number
            self.performSegueWithIdentifier("showPublicationStringFieldsEditor", sender: indexPath.row)
        case 2: // Address
            self.performSegueWithIdentifier("showPublicationAdressEditor", sender: indexPath.row)
        case 4, 5: // Start & End date
            self.performSegueWithIdentifier("showPublicationDateEditor", sender: indexPath.row)
        case 6: // Type of collection
            self.performSegueWithIdentifier("showPublicationTypeOfCollectionEditor", sender: indexPath.row)
        case 10: // Image picker
            self.presentImagePickerController()
        case 11: // Take off-air
            println("Case 11: \(indexPath.row)")
            takeOffAir()
        case 12: // Publish
            publish()
        default:
            break
        }
    }
    
    private func updateDataSource(newValue:AnyObject, selectedTagNumber:Int){
        switch selectedTagNumber {
        case 2:
            println("Case 2:")
            println(newValue)
            if let dic = newValue as? NSDictionary {
                dataSource[selectedTagNumber].userData = dic.valueForKey("address") as String
                dataSource[selectedTagNumber].cellText = dic.valueForKey("address") as String
                dataSource[selectedTagNumber].addressLatitude = dic.valueForKey("lat") as Double
                dataSource[selectedTagNumber].addressLongtitude = dic.valueForKey("lon") as Double
            }
        case 4:
            let locDateString = FCDateFunctions.localizedDateAndTimeStringShortStyle(newValue as NSDate)
            dataSource[selectedTagNumber].userData = newValue as NSDate
            dataSource[selectedTagNumber].cellText = kPublishStartDatePrefix + locDateString
        case 5:
            let locDateString = FCDateFunctions.localizedDateAndTimeStringShortStyle(newValue as NSDate)
            dataSource[selectedTagNumber].userData = newValue as NSDate
            dataSource[selectedTagNumber].cellText = kPublishEndDatePrefix + locDateString
        case 6:
            println("newValue: \(newValue)")
            dataSource[selectedTagNumber].userData = newValue as Int
            if newValue as Int == 1{
                dataSource[selectedTagNumber].cellText = kPublishTypeOfCollectionFreePickUp
            }
            else {
                dataSource[selectedTagNumber].cellText = kPublishTypeOfCollectionContactPublisher
            }
        case 8:
            dataSource[selectedTagNumber].userData = newValue as String
            dataSource[selectedTagNumber].cellText = (kPublishContactPhoneNumberPrefix + (newValue as String))
        default:
            dataSource[selectedTagNumber].userData = newValue as String
            dataSource[selectedTagNumber].cellText = newValue as String
        }
        
        
        dataSource[selectedTagNumber].containsUserData = true
        dataSource[selectedTagNumber].isObligatory = true
    }
    
    private func removeFromDataSource(atIndex:Int){
        dataSource.removeAtIndex(atIndex)
    }
    
    private func insertIntoDataSource(cellData: FCNewPublicationTVCCellData, index:Int){
        dataSource.insert(cellData, atIndex: index)
    }
    
    private func getImage(atIndex:Int, cellWidth:Double, cellHeight:Double)->UIImageView{
     
        
        let image = self.publication?.photoData.photo
        var imageView = UIImageView()
        if image != nil {
            imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        }
        return imageView
    }
    
    private func takeOffAir(){
        if let publication = self.publication {
            publication.isOnAir = false
        }
        println("Old end date: \(dataSource[5].userData)")
//        dataSource[5].userData = NSDate()
        updateDataSource(NSDate() , selectedTagNumber: 5)
        println("New end date: \(dataSource[5].userData)")
        isReadyForTakeOffAir = false
        //tableView.reloadData()
        println("Table was reloaded!!!!")
        reloadTableWithNewData()
    }
    
    private func setIsReadyForTakeOffAir(){
       
        if let publication = self.publication {
            if publication.isOnAir {isReadyForTakeOffAir = true}
            else {isReadyForTakeOffAir = false}
        }
        
//        
//        
//        if let startDate = dataSource[4].userData as? NSDate {
//            println("Start date is not nil")
//            if let endDate = dataSource[5].userData as? NSDate {
//                println("End date is not nil")
//                if startDate.compare(endDate) == NSComparisonResult.OrderedAscending {
//                    // If true: the startDate is earlier in time than endDate
//                    isReadyForTakeOffAir = true
//                }
//                else {
//                    isReadyForTakeOffAir = false
//                }
//            }
//            else {
//                println("End date is nil")
//                isReadyForTakeOffAir = false
//            }
//        }
//        else {
//            println("Start date is nil")
//            isReadyForTakeOffAir = false
//        }
//        
//        if isNewPublication {
//            isReadyForTakeOffAir = false
//        }
    }
    
    private func checkIfReadyForPublish(){
        //Check if all cell objects in dataSource are ready for publish
        for cellObj in dataSource {
            println("Pub test (\(cellObj.isObligatory)) (\(cellObj.identityTag)): \(cellObj.cellText)")
            if cellObj.isObligatory {
                isReadyForPublish = true
                //println("Set isReadyForPublish as true")
            }
            else {
                isReadyForPublish = false
                break
            }
            
        }
        println("isReadyForPublish = \(isReadyForPublish)")
    }
    
    private func reloadTableWithNewData(){
        setIsReadyForTakeOffAir()
        checkIfReadyForPublish()
        tableView.reloadData()
    }
    
    private func getImageObjectIndexFromDataSource() -> Int {
        var index = 0
        for var i = 0; i < dataSource.count; ++i {
            if dataSource[i].isImgCell {index = i}
        }
        return index
    }
    
    private func getAdjustedIndexPath(index:Int) -> Int {
        if dataSource.count < 12 {
            if index > 6 {return index+2}
        }
        
        return index
    }
    
    // MARK: - PublicationDataInputDelegate protocol
    
    
    ///
    /// this method is called when a new publication is ready to be published,
    ///  or when a user edited an existing publication. editing an existing publication
    ///  will result with a new publication with a unique id with the same id and
    ///  a different version number.
    ///
    func publish() {
        // For each publication we display the follwoing in the table:
        // 0.  Title
        // 1.  Subtitle
        // 2.  Address + latitude + longitude
        // 3.  Seperator
        // 4.  Start date
        // 5.  End date
        // 6.  Type of collection
        // 7.  Seperator
        // 8.  Contact info (phone number)
        // 9.  Seperator
        // 10. Photo
        // 11. Take of air button  (not part of the data source!!!)
        // 12. Publish button (not part of the data source!!!)
        // so a total of 13 members for in datasource.
        
        let title = self.dataSource[0].userData as String
        let subtitle = self.dataSource[1].userData as String
        let address = self.dataSource[2].userData as String
        let latitude = self.dataSource[2].addressLatitude as Double
        let longitude = self.dataSource[2].addressLongtitude as Double
        let startingDate = self.dataSource[4].userData as NSDate
        let endingDate = self.dataSource[5].userData as NSDate
        let typeOfCollecting = self.dataSource[6].userData as Int
        println("NEW PUBLICATION \(isNewPublication)")
       
        let image = self.dataSource[8].userData as UIImage
        
        
        
        

    
    
    
    
    
    
    }
    
    ///
    /// UIPhotoPickerDelegate
    ///
    func didFinishPickingPhoto(photo:UIImage) {
        
    }
    
    /// Mark - FCPublicationDataInputDelegate
    
    func didPickSubtitle(subtitle:String){
        
    }
    
    func didPickDate(date:NSDate){
        
    }
    
    func didPickTitle(title:String) {
        
    }
    
    func didPickTypeOfCollection(typeOfCollection: FCTypeOfCollecting ,withContactInfo contactinfo:String) {
        
    }
    
    func didPickAddress(address:String,withLocation coordinates:CLLocationCoordinate2D) {
        
    }
    
    func getCount() -> Int {
        if identityTagCounter == 0 {
            identityTagCounter++
            return 0
        }
        
        return identityTagCounter++
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        println("SENDER TAG: \(sender)")
        if (segue.identifier == "showPublicationStringFieldsEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishStringFieldsEditorVC
            if sender as Int != 1 {
                pubEditorVC.showTextField = true
            }
            pubEditorVC.dataSource = dataSource
            pubEditorVC.selectedTagNumber = sender as Int
        }
        
        if (segue.identifier == "showPublicationDateEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishDateEditorVC
            
            pubEditorVC.dataSource = dataSource
            pubEditorVC.selectedTagNumber = sender as Int
        }
        
        if (segue.identifier == "showPublicationTypeOfCollectionEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublicationTypeOfPublicationEditorVC
            
            pubEditorVC.dataSource = dataSource
            pubEditorVC.selectedTagNumber = sender as Int
        }
        
        if (segue.identifier == "showPublicationAdressEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishAddressEditorVC
            
            pubEditorVC.dataSource = dataSource
            pubEditorVC.selectedTagNumber = sender as Int
        }
        
        
        
    }
    
    
    //===========================================================================
    // Boris: Need to add functions to make this code more flexible and smarter
    //===========================================================================
    
    func createCellDataForExistingPublication(publication:FCPublication) {
        // For each publication we display the follwoing in the table:
        // 0.  Title
        // 1.  Subtitle
        // 2.  Address + latitude + longitude
        // 3.  Seperator
        // 4.  Start date
        // 5.  End date
        // 6.  Type of collection
        // 7.  Seperator
        // 8.  Contact info (phone number)
        // 9.  Seperator
        // 10. Photo
        // 11. Take of air button  (not part of the data source!!!)
        // 12. Publish button (not part of the data source!!!)
        // so a total of 13 members for in datasource.
        
        isNewPublication = false
        var  locDateString : String
        
        // define basic seperator object
        var cellDataSeperator = FCNewPublicationTVCCellData()
        cellDataSeperator.height = kSeperatorHeight
        cellDataSeperator.isSeperator = true
        cellDataSeperator.isObligatory = true
        
        // Check for image in publication
        if publication.photoData.photo != nil {
                isImageInPublication = true
        }
        
        // For Title
        //----------------------
        var cellData0 = FCNewPublicationTVCCellData()
        cellData0.containsUserData = true
        cellData0.cellText = publication.title
        cellData0.userData = publication.title
        cellData0.isObligatory = true
        cellData0.identityTag = getCount()
        dataSource.append(cellData0)
        
        // For Subtitle
        //----------------------
        var cellData1 = FCNewPublicationTVCCellData()
        if let sTitle = publication.subtitle {
            cellData1.containsUserData = true
            cellData1.cellText = sTitle
            cellData1.userData = sTitle
        }
        else {
            cellData1.cellText = kPublishSubtitle
            cellData1.userData = ""
        }
        cellData1.isObligatory = true
        cellData1.identityTag = getCount()
        dataSource.append(cellData1)
        
        // For Address
        //----------------------
        var cellData2 = FCNewPublicationTVCCellData()
        cellData2.containsUserData = true
        cellData2.cellText = publication.address
        cellData2.userData = publication.address
        cellData2.isObligatory = true
        cellData2.addressLatitude  = publication.coordinate.latitude
        cellData2.addressLongtitude = publication.coordinate.longitude
        cellData2.identityTag = getCount()
        dataSource.append(cellData2)
        
        // For a Seperator
        //----------------------
        cellDataSeperator.identityTag = getCount()
        dataSource.append(cellDataSeperator)
        
        // For Start Date
        //----------------------
        locDateString = FCDateFunctions.localizedDateAndTimeStringShortStyle(publication.startingDate)
        var cellData4 = FCNewPublicationTVCCellData()
        cellData4.containsUserData = true
        cellData4.cellText = kPublishStartDatePrefix + locDateString
        cellData4.userData = publication.startingDate
        cellData4.isObligatory = true
        cellData4.identityTag = getCount()
        dataSource.append(cellData4)
        
        // For End Date
        //----------------------
        locDateString = FCDateFunctions.localizedDateAndTimeStringShortStyle(publication.endingDate)
        var cellData5 = FCNewPublicationTVCCellData()
        cellData5.containsUserData = true
        cellData5.cellText = kPublishEndDatePrefix + locDateString
        cellData5.userData = publication.endingDate
        cellData5.isObligatory = true
        cellData5.identityTag = getCount()
        dataSource.append(cellData5)
        
        // For Type Of Collection
        //----------------------
        // default value for type of collection: Free Pickup
        var collectionType = publication.typeOfCollecting
        var cellData6 = FCNewPublicationTVCCellData()
        if collectionType == FCTypeOfCollecting.ContactPublisher {
            cellData6.cellText = kPublishTypeOfCollectionContactPublisher
            cellData6.userData = 2
        }
        else {
            cellData6.cellText = kPublishTypeOfCollectionFreePickUp
            cellData6.userData = 1
        }
        cellData6.containsUserData = true
        cellData6.isObligatory = true
        cellData6.identityTag = getCount()
        dataSource.append(cellData6)
        
        // For a Seperator
        //----------------------
        cellDataSeperator.identityTag = getCount()
        dataSource.append(cellDataSeperator)
        
        // For Contact Info
        //----------------------
        var cellData8 = FCNewPublicationTVCCellData()
        if collectionType == FCTypeOfCollecting.ContactPublisher {
            if let cInfo = publication.contactInfo {
                cellData8.containsUserData = true
                cellData8.cellText = kPublishContactPhoneNumberPrefix + cInfo
                cellData8.userData = cInfo
                cellData8.isObligatory = true
            }
            else {
                cellData8.containsUserData = false
                cellData8.cellText = kPublishContactPhoneNumber
            }
            cellData8.identityTag = getCount()
            dataSource.append(cellData8)
            
            // For a Seperator
            //----------------------
            cellDataSeperator.identityTag = getCount()
            dataSource.append(cellDataSeperator)
        }
        
        // For Photo
        //----------------------
        var cellData10 = FCNewPublicationTVCCellData()
        if isImageInPublication {
            cellData10.userData = self.publication?.photoData.photo as UIImage!
            cellData10.height = kImageCellHeight
            cellData10.containsUserData = true
            cellData10.isImgCell = true
            cellData10.isObligatory = true
        }
        else {
            cellData10.cellText = kPublishImage
        }
        cellData10.identityTag = getCount()
        dataSource.append(cellData10)
        
        // For Take of air button
        //----------------------
        var cellData11 = FCNewPublicationTVCCellData()
        cellData11.isTakeOffAirBuuton = true
        cellData11.isObligatory = true
        cellData11.identityTag = getCount()
        dataSource.append(cellData11)
        
        // For Publish button
        //----------------------
        var cellData12 = FCNewPublicationTVCCellData()
        cellData12.isPublishButton = true
        cellData12.isObligatory = true
        cellData12.identityTag = getCount()
        dataSource.append(cellData12)
        
        numberOfCells = dataSource.count
        
    }
    
    func createCellDataForNewPublication() {
        println("=== New Publication ===")
        var emptyCellData = FCNewPublicationTVCCellData()
        
        // define basic seperator object
        var cellDataSeperator = FCNewPublicationTVCCellData()
        cellDataSeperator.height = kSeperatorHeight
        cellDataSeperator.isSeperator = true
        
        // For Title
        //----------------------
        emptyCellData.cellText = kPublishTitle
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For Subtitle
        //----------------------
        emptyCellData.cellText = kPublishSubtitle
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For Address
        //----------------------
        emptyCellData.cellText = kPublishAddress
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For a Seperator
        //----------------------
        cellDataSeperator.identityTag = getCount()
        dataSource.append(cellDataSeperator)
        
        // For Start Date
        //----------------------
        emptyCellData.cellText = kPublishStartDate
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For End Date
        //----------------------
        emptyCellData.cellText = kPublishEndDate
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For Type Of Collection
        emptyCellData.cellText = kPublishTypeOfCollection
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For a Seperator
        //----------------------
        cellDataSeperator.identityTag = getCount()
        dataSource.append(cellDataSeperator)
        
        // For Contact Info
        //----------------------
        emptyCellData.cellText = kPublishContactPhoneNumber
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For a Seperator
        //----------------------
        cellDataSeperator.identityTag = getCount()
        dataSource.append(cellDataSeperator)
        
        // For Photo
        //----------------------
        emptyCellData.cellText = kPublishImage
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For Take of air button
        //----------------------
        emptyCellData.isTakeOffAirBuuton = true
        emptyCellData.isPublishButton = false
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        // For Publish button
        //----------------------
        emptyCellData.isTakeOffAirBuuton = false
        emptyCellData.isPublishButton = true
        emptyCellData.identityTag = getCount()
        dataSource.append(emptyCellData)
        
        numberOfCells = dataSource.count
        
        
    }
    
}

extension FCPublicationEditorTVC {
    
    func presentImagePickerController () {
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var myInfo = info
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as UIImage
            self.updateCellDataWithImage(image)
        }
        
    }
    
    func updateCellDataWithImage(anImage: UIImage) {
        //update data source
        self.dataSource[8].userData = anImage
        self.dataSource[8].containsUserData = true
        self.dataSource[8].isObligatory = true
        self.isImageInPublication = true
        println("THE GIVVEN NUMBER IS : \(getImageObjectIndexFromDataSource())")
        reloadTableWithNewData()
      //  self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 8, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

