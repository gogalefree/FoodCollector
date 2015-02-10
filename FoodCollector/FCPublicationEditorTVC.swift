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
let kPublishTitle = String.localizedStringWithFormat("הוסף שם", "Add title for a new event")
let kPublishSubtitle = String.localizedStringWithFormat("הוסף תיאור", "Add subitle for a new event")
let kPublishAddress = String.localizedStringWithFormat("הוסף כתובת", "Add address for a new event")
let kPublishTypeOfCollection = String.localizedStringWithFormat("הוסף צורת איסוף", "Select Type Of Collection for a new event")
let kPublishStartDate = String.localizedStringWithFormat("הוסף תאריך התחלה", "Add start date for a new event")
let kPublishEndDate = String.localizedStringWithFormat("הוסף תאריך סיום", "Add ebd date for a new event")
let kPublishImage = String.localizedStringWithFormat("הוסף תמונה", "Add image for a new event")
let kPublishPublishButtonLabel = String.localizedStringWithFormat("פרסם", "Publish button to publish a new event")
let kPublishTakeOffAirButtonLabel = String.localizedStringWithFormat("הסר פרסום", "Take Off Air button to immediately stop publication of an exciting active event")
let kPublishStartDatePrefix = String.localizedStringWithFormat("מתחיל:  ", "Start date label for displaying an exciting start date event")
let kPublishEndDatePrefix = String.localizedStringWithFormat("מסתיים: ", "End date label for displaying an exciting end date event")

let kSeperatHeaderHeight = CGFloat(30.0)


struct FCPublicationEditorTVCCellData {
    
    var containsUserData:Bool = false
    var cellTitle:String = ""
    var userData:AnyObject = ""
}

enum FCPublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
    case ActivityCenter
    
}

public enum FCTypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}

class FCPublicationEditorTVC : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var publication:FCPublication?
    var state = FCPublicationEditorTVCState.CreateNewPublication
    var dataSource = [FCPublicationEditorTVCCellData]()
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    var selectedIndexPath: NSIndexPath?
    var takeOffAirButtonEnabled = false
    var publishButtonEnabled = false
    
    func setupWithState(initialState: FCPublicationEditorTVCState, publication: FCPublication?) {
        self.state = initialState
        self.publication = publication
        prepareDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        shouldEnableTakeOfAirButton()
        checkIfReadyForPublish()
    }
    
    //MARK: - TableViewDataSource
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3, 6:
            return kSeperatHeaderHeight
            
        default:
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCell {
        
        let cellIdentifier = "publicationEditorTVCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as FCPublicationEditorTVCell
        cell.indexPath = indexPath
        cell.shouldEnablePublishButton = self.publishButtonEnabled
        cell.shouldEnableTakeOffAirButton = self.takeOffAirButtonEnabled
        cell.cellData = self.dataSource[indexPath.section]
        
        return cell
    }
    
    // Each section represents a cell
    // 0.  Title
    // 1.  Subtitle
    // 2.  Address + latitude + longitude
    // 3.  Start date
    // 4.  End date
    // 5.  Type of collection
    // 6.  Photo
    // 7.  Take off air button
    // 8.  Publish button
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedIndexPath = indexPath
        
        switch indexPath.section {
        case 0, 1: // Title, Subtutle
            self.performSegueWithIdentifier("showPublicationStringFieldsEditor", sender: nil)
        case 2: // Address
            self.performSegueWithIdentifier("showPublicationAdressEditor", sender: indexPath.row)
        case 3, 4: // Start & End date
            self.performSegueWithIdentifier("showPublicationDateEditor", sender: indexPath.row)
        case 5: // Type of collection
            self.performSegueWithIdentifier("showPublicationTypeOfCollectionEditor", sender: nil)
        case 6: // Image picker
            self.presentImagePickerController()
        case 7: // Take off-air
            takeOffAir()
            shouldEnableTakeOfAirButton()
        case 8: // Publish
            publish()
        default:
            break
        }
    }
    
    //MARK: - unwind from editors
    
    @IBAction func unwindFromStringFieldsEditorVC(segue: UIStoryboardSegue) {
        
        let sourceVC = segue.sourceViewController as FCPublishStringFieldsEditorVC
        let cellData = sourceVC.celldata
        let section = selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
    }
    
    
    @IBAction func unwindFromDateEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishDateEditorVC
        let cellData = sourceVC.cellData
        let section = self.selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
    }
    
    @IBAction func unwindFromTypeOfCollectionEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublicationTypeOfPublicationEditorVC
        let cellData = sourceVC.cellData
        let section = selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
    }
    
    @IBAction func unwindFromAddressEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishAddressEditorVC
        let cellData = sourceVC.cellData
        let section = selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
    }
    
    //MARK: - TakeOffAir and Publish buttons logic
    
    private func shouldEnableTakeOfAirButton() {
        
        switch self.state {
            
        case .EditPublication , .ActivityCenter:
            self.takeOffAirButtonEnabled = self.publication!.isOnAir
            
        default:
            self.takeOffAirButtonEnabled = false
        }
        
        checkIfReadyForPublish()
        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 7)], withRowAnimation: .Automatic)
    }
    
    private func takeOffAir(){
        
        if let publication = self.publication {
            //update model
            publication.isOnAir = false
            FCModel.sharedInstance.saveUserCreatedPublications()
            
            //update ui
            self.takeOffAirButtonEnabled = false
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 7)], withRowAnimation: .Automatic)
            
            //inform server and model
            FCModel.sharedInstance.foodCollectorWebServer.takePublicationOffAir(publication, completion: { (success) -> Void in
               
                if success{
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        let publicationIdentifier = PublicationIdentifier(uniqueId: self.publication!.uniqueId, version: self.publication!.version)
                        FCUserNotificationHandler.sharedInstance.recivedtoDelete.append(publicationIdentifier)
                        FCModel.sharedInstance.deletePublication(publicationIdentifier)
                    })
                }
                else{
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not take your event off air", aMessage: "try again later")
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    private func checkIfReadyForPublish(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var containsData = true
            
            //check cellData
            for index in 0...6 {
                
                let cellData = self.dataSource[index]
                if !cellData.containsUserData{
                    containsData = false
                    break
                }
            }
            
            //check dates
            var normalDates = true
            var expired = true
            
            if self.dataSource[3].containsUserData && self.dataSource[4].containsUserData {
                
                let startindDate =  self.dataSource[3].userData as NSDate
                let endingDate = self.dataSource[4].userData as NSDate
                expired = FCDateFunctions.PublicationDidExpired(endingDate)
                
                //check if ending date is later than starting date
                if startindDate.timeIntervalSince1970 >= endingDate.timeIntervalSince1970 {normalDates = false}
            }
            
            if normalDates && !expired && containsData && !self.takeOffAirButtonEnabled{
                self.publishButtonEnabled = true
            }
            else {
                self.publishButtonEnabled = false
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 8)], withRowAnimation: .Automatic)
                
            })
        })
    }
    
    func publish() {
        
        switch self.state {
        case .CreateNewPublication:
            publishNewCreatedPublication()
        case .EditPublication , .ActivityCenter:
            publishEdidtedPublication()
        }
    }
    
    func publishNewCreatedPublication() {
        var params = self.prepareParamsDictToSend()
        
        FCModel.sharedInstance.foodCollectorWebServer.postNewCreatedPublication(params, completion: {
            (success: Bool, uniqueID: Int, version: Int) -> () in
            if success {
                params[kPublicationUniqueIdKey] = uniqueID
                params[kPublicationVersionKey] = version
                let publication = FCPublication.userCreatedPublicationWithParams(params)
                publication.photoData.photo = self.dataSource[6].userData as? UIImage
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    
                    //add the new publication
                    FCModel.sharedInstance.addPublication(publication)
                    
                    //add user created publication
                    FCModel.sharedInstance.addUserCreatedPublication(publication)
                
                    
                    //send the photo
                    let uploader = FCPhotoFetcher()
                    uploader.uploadPhotoForPublication(publication)
                })
            }
                
            else {
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not post your event", aMessage: "try again later")
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    
    func publishEdidtedPublication() {
        
        var params = self.prepareParamsDictToSend()
        FCModel.sharedInstance.foodCollectorWebServer.postEditedPublication(params, publication: self.publication!) { (success, version) -> () in
            
            if success {
                
                params[kPublicationUniqueIdKey] = self.publication!.uniqueId
                params[kPublicationVersionKey] = version
                let publication = FCPublication.userCreatedPublicationWithParams(params)
                publication.photoData.photo = self.dataSource[6].userData as? UIImage
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if self.state == .EditPublication{
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    else if self.state == .ActivityCenter {
                        self.navigationController?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    FCModel.sharedInstance.addPublication(publication)
                    
                    FCModel.sharedInstance.addUserCreatedPublication(publication)
                    
                    let uploader = FCPhotoFetcher()
                    uploader.uploadPhotoForPublication(publication)
                })
            }
                
            else {
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not post your event",aMessage: "try again later")
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func prepareParamsDictToSend() -> [String: AnyObject]{
        // 0.  Title
        // 1.  Subtitle
        // 2.  Address + latitude + longitude
        // 3.  Start date
        // 4.  End date
        // 5.  Type of collection
        // 6.  Photo
        // 7.  Take off air button
        // 8.  Publish button
        var params = [String: AnyObject]()
        params[kPublicationTitleKey] = self.dataSource[0].userData as String
        params[kPublicationSubTitleKey] = self.dataSource[1].userData as String
        let addressDict = self.dataSource[2].userData as [String: AnyObject]
        params[kPublicationAddressKey] = addressDict["adress"] as String
        params[kPublicationlatitudeKey] = addressDict["Latitude"] as Double
        params[kPublicationLongtitudeKey] = addressDict["longitude"] as Double
        
        let strtingDate = self.dataSource[3].userData as NSDate
        let startingDateInterval = strtingDate.timeIntervalSince1970
        let startingDateInt: Int = Int(startingDateInterval)
        params[kPublicationStartingDateKey] = startingDateInt as Int
        
        let endingDate = self.dataSource[4].userData as NSDate
        let endingDateInterval = endingDate.timeIntervalSince1970
        let endingDateInt: Int = Int(endingDateInterval)
        params[kPublicationEndingDateKey] = endingDateInt as Int
        
        let typeOfCollectingDict = self.dataSource[5].userData as [String : AnyObject]
        params[kPublicationContactInfoKey] = typeOfCollectingDict[kPublicationContactInfoKey]
        params[kPublicationTypeOfCollectingKey] = typeOfCollectingDict[kPublicationTypeOfCollectingKey] as Int
        return params
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        
        let section = self.selectedIndexPath!.section
        let cellData = self.dataSource[section]
        
        if (segue.identifier == "showPublicationStringFieldsEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishStringFieldsEditorVC
            pubEditorVC.celldata = cellData
            pubEditorVC.state = FCPublishStringFieldsEditorVC.DisplayState(rawValue: section)!
        }
        
        if (segue.identifier == "showPublicationDateEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishDateEditorVC
            pubEditorVC.cellData = cellData
            pubEditorVC.state = FCPublishDateEditorVC.PickerState(rawValue: section)!
        }
        
        if (segue.identifier == "showPublicationTypeOfCollectionEditor") {
            let typeOfCollectingEditorVC = segue!.destinationViewController as FCPublicationTypeOfPublicationEditorVC
            typeOfCollectingEditorVC.cellData = cellData
        }
        
        if (segue.identifier == "showPublicationAdressEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishAddressEditorVC
            
        }
        
        
        
    }
}

extension  FCPublicationEditorTVC {
    //===========================================================================
    //MARK: - prepare cell data
    //===========================================================================
    
    func prepareDataSource() {
        // Each section represents a cell
        // 0.  Title
        // 1.  Subtitle
        // 2.  Address + latitude + longitude
        // 3.  Start date
        // 4.  End date
        // 5.  Type of collection
        // 6.  Photo
        // 7.  Take off air button
        // 8.  Publish button
        
        var initialTitles = [kPublishTitle, kPublishSubtitle, kPublishAddress, kPublishStartDate, kPublishEndDate,
            kPublishTypeOfCollection, kPublishImage, kPublishTakeOffAirButtonLabel, kPublishPublishButtonLabel]
        
        for index in 0...8 {
            
            var cellData = FCPublicationEditorTVCCellData()
            cellData.cellTitle = initialTitles[index]
            
            if self.state == .EditPublication || self.state == .ActivityCenter{
                
                if let publication = self.publication {
                  
                    switch index {
                        
                    case 0:
                        //publication title
                        cellData.userData = publication.title
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.title
                        
                    case 1:
                        //publication subTitle
                        cellData.userData = publication.subtitle ?? ""
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.subtitle ?? kPublishSubtitle
                        
                    case 2:
                        //publication address
                        var addressDict: [String: AnyObject] = ["adress":publication.address ,"Latitude":publication.coordinate.latitude, "longitude" : publication.coordinate.longitude]
                        cellData.userData = addressDict
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.address
                        
                    case 3:
                        //publication starting date
                        cellData.userData = publication.startingDate
                        cellData.containsUserData = true
                        let dateString = FCDateFunctions.localizedDateStringShortStyle(publication.startingDate)
                        let timeString = FCDateFunctions.timeStringEuroStyle(publication.startingDate)
                        let prefix = kPublishStartDatePrefix
                        let cellTitle = "\(prefix) \(dateString)   \(timeString)"
                        cellData.cellTitle = cellTitle
                        
                    case 4:
                        //publication ending date
                        cellData.userData = publication.endingDate
                        cellData.containsUserData = true
                        let dateString = FCDateFunctions.localizedDateStringShortStyle(publication.endingDate)

                        let timeString = FCDateFunctions.timeStringEuroStyle(publication.endingDate)
                        let prefix = kPublishEndDatePrefix
                        let cellTitle = "\(prefix) \(dateString)   \(timeString)"
                        cellData.cellTitle = cellTitle
                        
                    case 5:
                        //publication type of collecting
                        var contactInfo = publication.contactInfo ?? ""
                        var typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : publication.typeOfCollecting.rawValue , kPublicationContactInfoKey : contactInfo]
                        
                        cellData.userData = typeOfCollectingDict
                        cellData.containsUserData = true
                        var cellTitle = ""
                        switch publication.typeOfCollecting {
                        case .FreePickUp:
                            cellTitle = kTypeOfCollectingFreePickUpTitle
                        case .ContactPublisher:
                            let callString = String.localizedStringWithFormat("התקשר: ", "means call to be added before a phone number")
                            let contactInfo = publication.contactInfo ?? ""
                            cellTitle = "\(callString) \(contactInfo)"
                        }
                        cellData.cellTitle = cellTitle
                        
                    case 6:
                        //publication photo
                        if let photo = publication.photoData.photo {
                            
                            cellData.userData = photo
                            cellData.containsUserData = true
                        }
                        
                    case 7 , 8:
                        //take off air button
                        //publish button
                        cellData.containsUserData = true
                        
                    default:
                        break
                    }
                    
                }
            }
            self.dataSource.append(cellData)
        }
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
        var cellData = FCPublicationEditorTVCCellData()
        cellData.containsUserData = true
        cellData.userData = anImage
        let section = self.selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
    }
}

