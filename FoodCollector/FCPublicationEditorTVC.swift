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



let kPublishTypeOfCollectionFreePickUp = String.localizedStringWithFormat("Collection type: Free pickup", "Select Type Of Collection for a new event: Free pickup")
let kPublishTypeOfCollectionContactPublisher = String.localizedStringWithFormat("Collection type: Contact publisher", "Type Of Collection for a new event: Contact publisher")
let kPublishStartDatePrefix = String.localizedStringWithFormat("Start:\t", "Start date label for displaying an exciting start date event")
let kPublishEndDatePrefix = String.localizedStringWithFormat("End:\t", "End date label for displaying an exciting end date event")
let kPublishContactPhoneNumber = String.localizedStringWithFormat("Add phone number", "Add phone number for a new event")
let kPublishContactPhoneNumberPrefix = String.localizedStringWithFormat("Phone number: ", "Phone number label for displaying an exciting phone number")

let kSeperatHeaderHeight = CGFloat(30.0)
let kImageCellHeight = CGFloat(140.0)


/// represents the cell data of the editor.

struct FCPublicationEditorTVCCellData {
    
    var containsUserData:Bool = false
    var cellTitle:String = ""
    var userData:AnyObject = ""
}

enum FCPublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
    
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
    
    //Mark: - TableViewDataSource
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        if indexPath.section == 6 {
//            if self.dataSource[6].containsUserData {
//                return kImageCellHeight
//            }
//        }
//        return UITableViewAutomaticDimension
//    }
    
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
        cell.cellData = self.dataSource[indexPath.section]
        return cell
    }

    
    @IBAction func unwindFromStringFieldsEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishStringFieldsEditorVC
       
    }
    
   
    @IBAction func unwindFromDateEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishDateEditorVC
      
    }
    
    @IBAction func unwindFromTypeOfCollectionEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublicationTypeOfPublicationEditorVC
   
        reloadTableWithNewData()
    }
    
    @IBAction func unwindFromAddressEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as FCPublishAddressEditorVC
     
    }
    
    
    
    
    
    
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
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
    
    
    private func takeOffAir(){
  
    }
    
    
    private func checkIfReadyForPublish(){
        //Check if all cell objects in dataSource are ready for publish
      
        
    
    }
    
    private func reloadTableWithNewData(){
        
    }
    
   

    func publish() {
        
//        let title = self.dataSource[0].userData as String
//        let subtitle = self.dataSource[1].userData as String
//        let address = self.dataSource[2].userData as String
//        let latitude = self.dataSource[2].addressLatitude as Double
//        let longitude = self.dataSource[2].addressLongtitude as Double
//        let startingDate = self.dataSource[4].userData as NSDate
//        let endingDate = self.dataSource[5].userData as NSDate
//        let typeOfCollecting = self.dataSource[6].userData as Int
//        println("NEW PUBLICATION \(isNewPublication)")
//       
//        let image = self.dataSource[8].userData as UIImage
        
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        println("SENDER TAG: \(sender)")
        if (segue.identifier == "showPublicationStringFieldsEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishStringFieldsEditorVC
            
        }
        
        if (segue.identifier == "showPublicationDateEditor") {
            let pubEditorVC = segue!.destinationViewController as FCPublishDateEditorVC
           
        }
        
        if (segue.identifier == "showPublicationTypeOfCollectionEditor") {
        
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
        
            if self.state == .EditPublication {
                
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
                    
                    case 3:
                        //publication address
                        var addressDict: [String: AnyObject] = ["adress":publication.address ,"Latitude":publication.coordinate.latitude, "longitude" : publication.coordinate.longitude]
                        cellData.userData = addressDict
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.address

                    case 4:
                        //publication starting date
                        cellData.userData = publication.startingDate
                        cellData.containsUserData = true
                        cellData.cellTitle = FCDateFunctions.localizedDateAndTimeStringShortStyle(publication.startingDate)
                    case 5:
                        //publication ending date
                        cellData.userData = publication.endingDate
                        cellData.containsUserData = true
                        cellData.cellTitle = FCDateFunctions.localizedDateAndTimeStringShortStyle(publication.endingDate)
                    
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
     
    }
}

