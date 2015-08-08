//
//  PublicationEditorTVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 06/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

let kPublishTitle = String.localizedStringWithFormat("הוספת שם מוצר", "Add title for a new event")
let kPublishSubtitle = String.localizedStringWithFormat("הוספת תיאור", "Add subitle for a new event")
let kPublishAddress = String.localizedStringWithFormat("הוספת כתובת", "Add address for a new event")
let kPublishTypeOfCollection = String.localizedStringWithFormat("הוספת סגנון איסוף", "Select Type Of Collection for a new event")
let kPublishStartDate = String.localizedStringWithFormat("הוספת תאריך התחלה", "Add start date for a new event")
let kPublishEndDate = String.localizedStringWithFormat("הוספת תאריך סיום", "Add ebd date for a new event")
let kPublishImage = String.localizedStringWithFormat("הוספת תמונה", "Add image for a new event")
let kPublishPublishButtonLabel = String.localizedStringWithFormat("פרסום", "Publish button to publish a new event")
let kPublishTakeOffAirButtonLabel = String.localizedStringWithFormat("הסרת פרסום", "Take Off Air button to immediately stop publication of an exciting active event")
let kPublishStartDatePrefix = String.localizedStringWithFormat("התחלה:  ", "Start date label for displaying an exciting start date event")
let kPublishEndDatePrefix = String.localizedStringWithFormat("סיום: ", "End date label for displaying an exciting end date event")

let kSeperatHeaderHeight = CGFloat(30.0)

let kAddDefaultHoursToStartDate:Double = 24 // Amount of hours to add to the start date so that we will have an End date for new publication only!
let kTimeIntervalInSecondsToEndDate = kAddDefaultHoursToStartDate * 60.0 * 60.0 // Hours * 60 Minutes * 60 seconds

struct FCPublicationEditorTVCCellData {
    
    var containsUserData:Bool = false
    var cellTitle:String = ""
    var userData:AnyObject = ""
}

enum PublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
}

public enum TypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}


class PublicationEditorTVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var publication:FCPublication?
    var state = PublicationEditorTVCState.CreateNewPublication
    var dataSource = [FCPublicationEditorTVCCellData]()
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    var selectedIndexPath: NSIndexPath?
    var takeOffAirButtonEnabled = false
    var publishButtonEnabled = false
    lazy var activityIndicatorBlureView = UIVisualEffectView()
    
    func setupWithState(initialState: PublicationEditorTVCState, publication: FCPublication?) {
        self.state = initialState
        self.publication = publication
        prepareDataSource()
        /*
        if self.state == .CreateNewPublication {
            self.deleteButton.enabled = false
        }
        */
    
        if self.state == .EditPublication {
            self.fetchPhotoIfNeeded()
        }
        
        
        println(">>>> show self.dataSource")
        for dataObj in self.dataSource {
            println(dataObj.cellTitle)
            println(dataObj.containsUserData)
            println(dataObj.userData)
            println("-------------------------")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCOnlyLabelCustomCell", bundle: nil), forCellReuseIdentifier: "onlyLabelCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCStartEndDateCustomCell", bundle: nil), forCellReuseIdentifier: "startEndDateCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCContactPublisherCustomCell", bundle: nil), forCellReuseIdentifier: "contactPublisherCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCImageCustomCell", bundle: nil), forCellReuseIdentifier: "imageCustomCell")
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    // Section and Cells outline:
    // ----------------------------------------------------
    // Section 0 - Title (has a scetion header)
    //    Cell 0 - Label or Text field
    // Section 1 - Address
    //    Cell 0 - Label (clicking it loads a view for adding address)
    // Section 2 - Start Date (has a scetion header)
    //    Cell 0 - Label
    //    Cell 1 - Date Picker
    // Section 3 - End Date
    //    Cell 0 - Label
    //    Cell 1 - Date Picker
    // Section 4 - Contact publisher?
    //    Cell 0 - Label + Switch button
    //    Cell 1 - Text field
    // Section 5 - Image (has a scetion header)
    //    Cell 0 - Label + add Image button + small UIview to display selected image
    // Section 6 - More Detials
    //    Cell 0 - Label or Text view

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    final override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 2, 5:
            return 30
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2: // Start Date Section
            return 1
        case 3: // End Date Section
            return 1
        case 4: // Contact publisher? Section
            return 1
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 6:
            return 90
        default:
            return 45
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 2, 3: // Start & End Date Sections
            
            let dateCell = tableView.dequeueReusableCellWithIdentifier("startEndDateCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCStartEndDateCustomCell
            dateCell.cellLabel.text = "Section \(indexPath.section), Row \(indexPath.item)"
            dateCell.dateValueLabel.text = "23/07/15 17:39"
            return dateCell
            
        case 4: // Contact publisher? Section
            
            let contactPublisherCell = tableView.dequeueReusableCellWithIdentifier("contactPublisherCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCContactPublisherCustomCell
            contactPublisherCell.cellLabel.text = "Section \(indexPath.section), Row \(indexPath.item)"
            return contactPublisherCell
        
        case 5: // Image Section
            
            let imageCell = tableView.dequeueReusableCellWithIdentifier("imageCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCImageCustomCell
            imageCell.cellLabel.text = "Section \(indexPath.section), Row \(indexPath.item)"
            return imageCell

        default: // All other sections (Only one label cells)
            let onlyLabelCell = tableView.dequeueReusableCellWithIdentifier("onlyLabelCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCOnlyLabelCustomCell
            
            onlyLabelCell.cellLabel.text = "Section \(indexPath.section), Row \(indexPath.item)"
            if (indexPath.section==6) {
                onlyLabelCell.cellLabel.frame.size.height = 90
            }
            return onlyLabelCell
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchPhotoIfNeeded() {
        
        if let publication = self.publication {
            if (publication.photoData.photo == nil) {
                let photoFetcher = FCPhotoFetcher()
                photoFetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                    var cellData = self.dataSource[6]
                    if let photo = image {
                        cellData.userData = photo
                        cellData.containsUserData = true
                        self.dataSource[6] = cellData
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 6)], withRowAnimation: .Automatic)
                        })
                    }
                })
            }
        }
    }

}



extension  PublicationEditorTVC {
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
                            let callString = String.localizedStringWithFormat("קשר טלפוני: ", "means call to be added before a phone number")
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
            else { // Create defaults for new empty publication
                println(">>> Create defaults for new empty publication")
                
                switch index {
                    
                case 3:
                    //publication starting date
                    cellData.userData = NSDate()
                    cellData.containsUserData = true
                    let dateString = FCDateFunctions.localizedDateStringShortStyle(cellData.userData as! NSDate)
                    let timeString = FCDateFunctions.timeStringEuroStyle(cellData.userData as! NSDate)
                    let prefix = kPublishStartDatePrefix
                    let cellTitle = "\(prefix) \(dateString)   \(timeString)"
                    cellData.cellTitle = cellTitle
                    
                case 4:
                    //publication ending date
                    cellData.userData = NSDate().dateByAddingTimeInterval(kTimeIntervalInSecondsToEndDate)
                    cellData.containsUserData = true
                    let dateString = FCDateFunctions.localizedDateStringShortStyle(cellData.userData as! NSDate)
                    let timeString = FCDateFunctions.timeStringEuroStyle(cellData.userData as! NSDate)
                    let prefix = kPublishEndDatePrefix
                    let cellTitle = "\(prefix) \(dateString)   \(timeString)"
                    cellData.cellTitle = cellTitle
                    
                case 5:
                    //publication type of collecting
                    var typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : 1 , kPublicationContactInfoKey : "no"]
                    
                    cellData.userData = typeOfCollectingDict
                    cellData.containsUserData = true
                    cellData.cellTitle = kTypeOfCollectingFreePickUpTitle
                case 6:
                    //publication photo
                    //cellData.userData = ""
                    cellData.containsUserData = true
                    
                default:
                    break
                }
            }
            self.dataSource.append(cellData)
        }
    }
}

extension PublicationEditorTVC {
    
    func presentImagePickerActionSheet() {
        
        let actionSheet = UIAlertController(title: "", message:"", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let dissmissAction = UIAlertAction(title:String.localizedStringWithFormat("ביטול", "alert dissmiss button title"), style: .Cancel) { (action) in
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let cameraAction = UIAlertAction(title:String.localizedStringWithFormat("מצלמה", "camera button title "), style: UIAlertActionStyle.Default) { (action) in
            self.presentImagePickerController(.Camera)
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let photoLibraryAction = UIAlertAction(title:String.localizedStringWithFormat("גלריה", "photo galery button title"), style: UIAlertActionStyle.Default) { (action) in
            self.presentImagePickerController(.PhotoLibrary)
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(dissmissAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func presentImagePickerController (source: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = source
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var myInfo = info
        if info[UIImagePickerControllerEditedImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
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
