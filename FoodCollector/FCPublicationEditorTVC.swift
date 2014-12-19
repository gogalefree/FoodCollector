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


/// represents the cell data of the editor.

struct FCNewPublicationTVCCellData {
    
    var height:CGFloat
    var containsUserData:Bool // Check if there's data for this cell. if not display default title
    var initialTitle:String
    var isObligatory:Bool // Check if we can publish (All data is entered by user)
    var userData:AnyObject
    var isSeperator:Bool
    var identityTag:Int
    // var newPublicationTVC:FCPublicationEditorTVC
    
}
/*
enum FCPublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
    
}
*/

public enum FCTypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}

///
/// handles the creation of a new publication or the editing of an existing
///  one.
///
class FCPublicationEditorTVC : UITableViewController,FCPublicationDataInputDelegate {
    
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
    let kPublishPublishButtonLabel = String.localizedStringWithFormat("Publish", "Publish button to publish a new event")
    let kPublishContactPhoneNumber = String.localizedStringWithFormat("Add phone number", "Add phone number for a new event")
    let kPublishContactPhoneNumberPrefix = String.localizedStringWithFormat("Phone number: ", "Phone number label for displaying an exciting phone number")
    let kPublishImage = String.localizedStringWithFormat("Add image", "Add image for a new event")
        
    var publication:FCPublication?
    var dataSource = [FCNewPublicationTVCCellData]()
    var identityTagCounter = 0
    var isDataSourceEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isDataSourceEdited {
            println("isDataSourceEdited = true")
            println(dataSource[0].userData)
            isDataSourceEdited = false
            println("Start: tableView.reloadData()")
            tableView.reloadData()
            println("End: tableView.reloadData()")
        }
        else {
            if publication != nil {
                self.createCellDataForExistingPublication(publication!)
            }
            else {
                self.createCellDataForNewPublication()
            }
        }
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("Start: tableView: numberOfRowsInSection")
        //println("End: tableView: numberOfRowsInSection")
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //println("Start: tableView: heightForRowAtIndexPath")
        //println("End: tableView: heightForRowAtIndexPath")
        if dataSource[indexPath.item].isSeperator {
            return dataSource[indexPath.item].height
        }
        return dataSource[indexPath.item].height
    }
    
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("row selected")
        dataSource[indexPath.item].height = 80.0
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCell {
        //println("Start: tableView: cellForRowAtIndexPath")
        
        let cellIdentifier = "publicationEditorTVCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        if dataSource[indexPath.item].isSeperator {
            cell.textLabel!.text = ""
            cell.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.00)
        }
        else {
          cell.textLabel!.text = dataSource[indexPath.item].initialTitle
        }
        
        cell.tag = dataSource[indexPath.item].identityTag
        //println("End: tableView: cellForRowAtIndexPath")
        return cell
    }

    // MARK: - PublicationDataInputDelegate protocol
    
    
    ///
    /// this method is called when a new publication is ready to be published,
    ///  or when a user edited an existing publication. editing an existing publication
    ///  will result with a new publication with a unique id with the same id and
    ///  a different version number.
    ///
    func publish() {
        
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
        if (segue.identifier == "showPublicationTitleEditor") {
            let pubTitleEditorVC = segue!.destinationViewController as FCPublishTitleEditorVC
            pubTitleEditorVC.dataSource = dataSource
            pubTitleEditorVC.selectedTagNumber = sender.tag
            println("SENDER TAG: \(sender.tag)")
            
        }
    }
    
        
    //===========================================================================
    // Boris: Need to add functions to make this code more flexible and smarter
    //===========================================================================
    
    func createCellDataForExistingPublication(publication:FCPublication) {
        println("=== Edit Publication ===")
        var cellData : FCNewPublicationTVCCellData
        var  locDateString : String
        
        // For Title
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: publication.title, isObligatory: false, userData: publication.title, isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Subtitle
        if let sTitle = publication.subtitle {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: sTitle, isObligatory: false, userData: sTitle, isSeperator: false, identityTag: getCount())
            
        }
        else {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: false, initialTitle: kPublishSubtitle, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        }
        dataSource.append(cellData)
        
        // For Address
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: publication.address, isObligatory: false, userData: publication.address, isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For a Seperator
        cellData = FCNewPublicationTVCCellData(height: 30.0, containsUserData: false, initialTitle: "", isObligatory: false, userData: "", isSeperator: true, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Start Date
        locDateString = FCDateFunctions.localizedDateStringShortStyle(publication.startingDate)
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: (kPublishStartDatePrefix + locDateString), isObligatory: false, userData: publication.startingDate, isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For End Date
        locDateString = FCDateFunctions.localizedDateStringShortStyle(publication.endingDate)
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: (kPublishEndDatePrefix + locDateString), isObligatory: false, userData: publication.endingDate, isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Type Of Collection
        var collectionType = publication.typeOfCollecting
        if collectionType == FCTypeOfCollecting.FreePickUp {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishTypeOfCollectionFreePickUp, isObligatory: false, userData: 1, isSeperator: false, identityTag: getCount())
        }
        else if collectionType == FCTypeOfCollecting.ContactPublisher {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishTypeOfCollectionContactPublisher, isObligatory: false, userData: 2, isSeperator: false, identityTag: getCount())
        }
        else {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishTypeOfCollection, isObligatory: false, userData: Int(), isSeperator: false, identityTag: getCount())
        }
        dataSource.append(cellData)
        
        // For a Seperator
        cellData = FCNewPublicationTVCCellData(height: 30.0, containsUserData: false, initialTitle: "", isObligatory: false, userData: "", isSeperator: true, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Contact Info
        if collectionType == FCTypeOfCollecting.ContactPublisher {
            if let cInfo = publication.contactInfo {
                cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: (kPublishContactPhoneNumberPrefix + cInfo), isObligatory: false, userData: cInfo, isSeperator: false, identityTag: getCount())
            }
            else {
                cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: false, initialTitle: kPublishContactPhoneNumber, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
            }
            dataSource.append(cellData)
            
            // For a Seperator
            cellData = FCNewPublicationTVCCellData(height: 30.0, containsUserData: false, initialTitle: "", isObligatory: false, userData: "", isSeperator: true, identityTag: getCount())
            dataSource.append(cellData)
        }
        
        // For Photo
        if let imgURL = publication.photoUrl {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: String(), isObligatory: false, userData: imgURL, isSeperator: false, identityTag: getCount())
        }
        else {
            cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: false, initialTitle: kPublishImage, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        }
        dataSource.append(cellData)
        
        println("Number of cells in table: \(dataSource.count)")
        
    }
    
    func createCellDataForNewPublication() {
        println("=== New Publication ===")
        var cellData : FCNewPublicationTVCCellData
        
        // For Title
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishTitle, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Subtitle
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: false, initialTitle: kPublishSubtitle, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Address
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishAddress, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For a Seperator
        cellData = FCNewPublicationTVCCellData(height: 30.0, containsUserData: false, initialTitle: "", isObligatory: false, userData: "", isSeperator: true, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Start Date
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishStartDate, isObligatory: false, userData: NSDate(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For End Date
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishEndDate, isObligatory: false, userData: NSDate(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Type Of Collection
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: true, initialTitle: kPublishTypeOfCollection, isObligatory: false, userData: Int(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For a Seperator
        cellData = FCNewPublicationTVCCellData(height: 30.0, containsUserData: false, initialTitle: "", isObligatory: false, userData: "", isSeperator: true, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Contact Info
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: false, initialTitle: kPublishContactPhoneNumber, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        // For a Seperator
        cellData = FCNewPublicationTVCCellData(height: 30.0, containsUserData: false, initialTitle: "", isObligatory: false, userData: "", isSeperator: true, identityTag: getCount())
        dataSource.append(cellData)
        
        // For Photo
        cellData = FCNewPublicationTVCCellData(height: 50.0, containsUserData: false, initialTitle: kPublishImage, isObligatory: false, userData: String(), isSeperator: false, identityTag: getCount())
        dataSource.append(cellData)
        
        println("Number of cells in table: \(dataSource.count)")
        
        
    }

}

