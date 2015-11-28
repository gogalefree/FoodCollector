//
//  PublicationEditorTVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 06/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

let kPublishTitle = String.localizedStringWithFormat("מה תרצה לשתף?", "Add title for a new event")

let kPublishAddress = String.localizedStringWithFormat("מאיפה לאסוף?", "Add address for a new event")
let kPublishPhoneNumber = String.localizedStringWithFormat("מה מספר הטלפון?", "Add phone number for a new event")
let kPublishStartDate = String.localizedStringWithFormat("אפשר לאסוף החל מ-", "Add start date for a new event")
let kPublishEndDate = String.localizedStringWithFormat("ועד-", "Add ebd date for a new event")
let kPublishImage = String.localizedStringWithFormat("רוצה להוסיף תמונה?", "Add image for a new event")
let kPublishedImage = String.localizedStringWithFormat("זו התמונה שבחרת:", "This is the image you have selected label")
let kPublishPublishButtonLabel = String.localizedStringWithFormat("פרסום", "Publish button to publish a new event")
let kPublishSubtitle = String.localizedStringWithFormat("רוצה לתת פרטים נוספים?", "Add subitle for a new event")
let kPublishtopRightBarButtonSaveTitle = String.localizedStringWithFormat("שמירה", "'Save' title for top right bar button")


let kAddDefaultHoursToStartDate:Double = 72 // Amount of hours to add to the start date so that we will have an End date for new publication only!
let kTimeIntervalInSecondsToEndDate = kAddDefaultHoursToStartDate * 60.0 * 60.0 // Hours * 60 Minutes * 60 seconds

struct PublicationEditorTVCCellData {
    
    var containsUserData:Bool = false
    var cellTitle:String = ""
    var userData:AnyObject = ""
}

enum PublicationEditorTVCState {
    
    case EditPublication
    case CreateNewPublication
}

//enum CellState {
//    
//    case Edit
//    case Display
//}

public enum TypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}


class PublicationEditorTVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CellInfoDelegate {
    
    var publication:FCPublication?
    var state = PublicationEditorTVCState.CreateNewPublication
    var dataSource = [PublicationEditorTVCCellData]()
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    var selectedIndexPath: NSIndexPath?
    //var takeOffAirButtonEnabled = false
    var publishButtonEnabled = false
    lazy var activityIndicatorBlureView = UIVisualEffectView()
    
    let defaultRowHeigt = CGFloat(45)
    let pictureRowHeigt = CGFloat(165)
    
    var showStartDatePickerCell = false
    var showEndDatePickerCell = false
    //var contactPublisherSelected = true // For new publication it sets the default value of the contact publisher data and switch state. It also, reflects the state of the switch in contact publisher row.

    func setupWithState(initialState: PublicationEditorTVCState, publication: FCPublication?) {
        // This function is executed before viewDidLoad()
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
        
        // Check the state of Contact Publisher
        //let contactValueRawValue = (dataSource[5].userData as! [String : AnyObject])[kPublicationTypeOfCollectingKey] as! Int
        //if (contactValueRawValue == 1) {
        //    contactPublisherSelected = false
        //}
        
        print(">>>> show self.dataSource")
        for dataObj in self.dataSource {
            print(dataObj.cellTitle)
            print(dataObj.containsUserData)
            print(dataObj.userData)
            print("-------------------------")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        addTopRightButton()
        addPictureButton()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButtonLabel, style: UIBarButtonItemStyle.Done, target: self, action: "backButtonAction")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCTextFieldCustomCell", bundle: nil), forCellReuseIdentifier: "textFieldCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCOnlyLabelCustomCell", bundle: nil), forCellReuseIdentifier: "onlyLabelCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCStartEndDateCustomCell", bundle: nil), forCellReuseIdentifier: "startEndDateCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCDatePickerCustomCell", bundle: nil), forCellReuseIdentifier: "datePickerCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCPhoneNumEditorCustomCell", bundle: nil), forCellReuseIdentifier: "phoneNumEditorCustomCell")
        
        self.tableView.registerNib(UINib(nibName: "PublicationEditorTVCImageCustomCell", bundle: nil), forCellReuseIdentifier: "imageCustomCell")
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        

    }
    
    func backButtonAction() {
        self.popViewController()
        GAController.sendAnalitics(kFAPublicationEditorTVCScreenName, action: "Back button action", label: "canceled publication creation or edit", value: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//===========================================================================
//   MARK: - TableView Functions
//===========================================================================

    
    // Sections and Cells outline:
    // ----------------------------------------------------
    // Section 0 - Image
    //    Cell 0 - UIview to display selected image
    
    // Section 1 - Title
    //    Cell 0 - Text field
    
    // Section 2 - Address
    //    Cell 0 - Label (clicking it loads a view for adding address)
    
    // Section 3 - Start Date
    //    Cell 0 - Label
    //    Cell 1 - Date Picker
    
    // Section 4 - End Date
    //    Cell 0 - Label
    //    Cell 1 - Date Picker
    
    // Section 5 - Phone Number
    //    Cell 0 - Text field
    
    // Section 6 - More Detials
    //    Cell 0 - Text field
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3: // Start Date Section
            if (showStartDatePickerCell) {return 2}
            return 1
        case 4: // End Date Section
            if (showEndDatePickerCell) {return 2}
            return 1
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return pictureRowHeigt
        case 3, 4:
            if (showStartDatePickerCell || showEndDatePickerCell) {
                if (indexPath.row == 1) {
                    return 162
                }
                else{
                    return defaultRowHeigt
                }
            }
            return defaultRowHeigt
        default:
            return defaultRowHeigt
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0) //(top, left, bottom, right)
        cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0) //(top, left, bottom, right)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 0: // Image Section
            
            let imageCell = tableView.dequeueReusableCellWithIdentifier("imageCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCImageCustomCell
            imageCell.cellData = self.dataSource[indexPath.section]
            imageCell.section = indexPath.section
            imageCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return imageCell
            
        case 1: // Subject Section
            let textFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCTextFieldCustomCell
            textFieldCell.cellData = self.dataSource[indexPath.section]
            textFieldCell.section = indexPath.section
            textFieldCell.delegate = self
            textFieldCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return textFieldCell
            
        case 2: // Address section
            let onlyLabelCell = tableView.dequeueReusableCellWithIdentifier("onlyLabelCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCOnlyLabelCustomCell
            onlyLabelCell.cellData = self.dataSource[indexPath.section]
            
            return onlyLabelCell

        case 3, 4: // Start & End Date Sections
            if (indexPath.row == 0) {
                let dateCell = tableView.dequeueReusableCellWithIdentifier("startEndDateCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCStartEndDateCustomCell
                dateCell.cellData = self.dataSource[indexPath.section]

                return dateCell
            }
            else {
                let datePickerCell = tableView.dequeueReusableCellWithIdentifier("datePickerCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCDatePickerCustomCell
                datePickerCell.minimumDate = self.dataSource[3]
                datePickerCell.section = indexPath.section
                datePickerCell.cellData = self.dataSource[indexPath.section]
                datePickerCell.delegate = self
                datePickerCell.selectionStyle = UITableViewCellSelectionStyle.None
                
                return datePickerCell
            }
            
        case 5: // Phone Number Section
            
            let phoneNumEditorCell = tableView.dequeueReusableCellWithIdentifier("phoneNumEditorCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCPhoneNumEditorCustomCell
            phoneNumEditorCell.cellData = self.dataSource[indexPath.section]
            phoneNumEditorCell.section = indexPath.section
            phoneNumEditorCell.delegate = self
            phoneNumEditorCell.selectionStyle = UITableViewCellSelectionStyle.None

            return phoneNumEditorCell

        case 6: // More Info Section
            let textFieldCell = tableView.dequeueReusableCellWithIdentifier("textFieldCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCTextFieldCustomCell
            textFieldCell.cellData = self.dataSource[indexPath.section]
            textFieldCell.section = indexPath.section
            textFieldCell.delegate = self
            textFieldCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return textFieldCell
        
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
            cell.textLabel?.text = self.dataSource[indexPath.section].cellTitle
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.view.endEditing(true)
        
        switch indexPath.section {
            
        case 2: // Address
            closeDatePicker()
            self.performSegueWithIdentifier("showPublicationAdressEditor", sender: indexPath.row)
            
        case 3: // Start date
            // Close the End date picker
            if (showEndDatePickerCell) {
                showEndDatePickerCell = false
                tableView.reloadSections(NSIndexSet(index: indexPath.section+1), withRowAnimation: .Automatic)
            }
            if (showStartDatePickerCell) {
                showStartDatePickerCell = false
            }
            else {
                showStartDatePickerCell = true
            }
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            
        case 4: // End date
            // Close the Start date picker
            if (showStartDatePickerCell) {
                showStartDatePickerCell = false
                tableView.reloadSections(NSIndexSet(index: indexPath.section-1), withRowAnimation: .Automatic)
            }
            if (showEndDatePickerCell) {
                showEndDatePickerCell = false
            }
            else {
                showEndDatePickerCell = true
            }
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        
        default: // Title, Subtitle (More Info)
            break
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedIndexPath = indexPath
        
        switch indexPath.section {
        case 0: // Image Section - disable didSelectRowAtIndexPath
            return nil
        default:
            return indexPath
        }
    }
    
    func closeDatePicker() {
        // If the user clicked a cell that is not the start or end date cell, and one of the date pickers is visible, then close it.
        if (showStartDatePickerCell) {
            showStartDatePickerCell = false
            tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
        }
        if (showEndDatePickerCell) {
            showEndDatePickerCell = false
            tableView.reloadSections(NSIndexSet(index: 4), withRowAnimation: .Automatic)
        }
    }

    
    func updateData(data:PublicationEditorTVCCellData, section: Int){
        dataSource[section] = data
        
        // If it's not the image cell (section=0), reload section.
        if section != 0 {tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)}
        
        checkIfReadyForPublish()
    }


//===========================================================================
//   MARK: - Navigation Functions
//===========================================================================

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func unwindFromAddressEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as! FCPublishAddressEditorVC
        let cellData = sourceVC.cellData
        let section = selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
        checkIfReadyForPublish()
    }
    
    func popViewController() {
        if state == PublicationEditorTVCState.CreateNewPublication {
            self.navigationController!.popViewControllerAnimated(true)
        }
        else {
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func addTopRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "V_Button"), style: UIBarButtonItemStyle.Done, target: self, action: "publish")
            
            //UIBarButtonItem(title: kPublishtopRightBarButtonSaveTitle, style: UIBarButtonItemStyle.Done, target: self, action: "publish")
        setTopRightButtonStatus()
    }
    
    func setTopRightButtonStatus(){
        self.navigationItem.rightBarButtonItem!.enabled = publishButtonEnabled
    }
    
    func addPictureButton(){
        let image = UIImage(named: "CameraIcon") as UIImage?
        let button   = UIButton(type: UIButtonType.Custom)
        button.frame = CGRectMake(40, pictureRowHeigt-25, 50, 50)
        button.backgroundColor = kNavBarBlueColor //UIColor(red: 0.0, green: 128/255, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = CGRectGetWidth(button.frame) / 2
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: "pictureButtonTouched:", forControlEvents:.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func pictureButtonTouched(object : UIButton) {
        
        print("Picture button pressed!!!")
        presentImagePickerActionSheet()
        
    }
    

//===========================================================================
//   MARK: - Publish buttons logic
//===========================================================================
    
    private func checkIfReadyForPublish(){
        var containsData = true
            
        //check cellData
        // Photo and More Info (index 0 & 6) are optional. containsUserData can be false when publishing.
        
        for index in 1...5 {
            
            let cellData = self.dataSource[index]
            if !cellData.containsUserData {
                containsData = false
                break
            }
        }
            
        //check dates
        var normalDates = true
        var expired = true
        
        if self.dataSource[3].containsUserData && self.dataSource[4].containsUserData {
            
            let startindDate =  self.dataSource[3].userData as! NSDate
            let endingDate = self.dataSource[4].userData as! NSDate
            expired = FCDateFunctions.PublicationDidExpired(endingDate)
            
            //check if ending date is later than starting date
            if startindDate.timeIntervalSince1970 >= endingDate.timeIntervalSince1970 {normalDates = false}
        }
        
        if normalDates && !expired && containsData /*&& !self.takeOffAirButtonEnabled*/ {
            self.publishButtonEnabled = true
        }
        else {
            self.publishButtonEnabled = false
        }
        
        self.setTopRightButtonStatus()
    }
    
    func publish() {
        
        addActivityIndicator()
        
        switch self.state {
        case .CreateNewPublication:
            publishNewCreatedPublication()
        case .EditPublication /*, .ActivityCenter*/:
            publishEdidtedPublication()
        }
    }
    
    func addActivityIndicator() {
        self.activityIndicatorBlureView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150))
        let offset = self.tableView.contentOffset.y
        let center = CGPointMake(FCDeviceData.screenWidth() / 2, FCDeviceData.screenHight() / 2 + offset )
        self.activityIndicatorBlureView.frame = CGRectMake(0, 0, 150, 150)
        self.activityIndicatorBlureView.center = center
        self.activityIndicatorBlureView.alpha = 0
        self.activityIndicatorBlureView.contentView.addSubview(activityIndicator)
        self.activityIndicatorBlureView.layer.cornerRadius = 20
        self.activityIndicatorBlureView.clipsToBounds = true
        
        
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor.darkGrayColor()
        activityIndicator.startAnimating()
        
        self.view.addSubview(self.activityIndicatorBlureView)
        self.view.bringSubviewToFront(self.activityIndicatorBlureView)
        self.activityIndicatorBlureView.animateToAlphaWithSpring(0.6, alpha: 1)
        self.tableView.userInteractionEnabled = false
        
    }
    
    func publishNewCreatedPublication() {
        
        var params = self.prepareParamsDictToSend()
        
        FCModel.sharedInstance.foodCollectorWebServer.postNewCreatedPublication(params, completion: {
            (success: Bool, uniqueID: Int, version: Int) -> () in
            if success {
                params[kPublicationUniqueIdKey] = uniqueID
                params[kPublicationVersionKey] = version
                let publication = FCPublication.userCreatedPublicationWithParams(params)
                publication.photoData.photo = self.dataSource[0].userData as? UIImage
                /*
                if publication.photoData.photo != nil {
                //send the photo
                let uploader = FCPhotoFetcher()
                uploader.uploadPhotoForPublication(publication)
                }
                */
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    
                    //add the new publication
                    FCModel.sharedInstance.addPublication(publication)
                    
                    //add user created publication
                    FCModel.sharedInstance.addUserCreatedPublication(publication)
                    
                    
                    if publication.photoData.photo != nil {
                        //send the photo
                        let uploader = FCPhotoFetcher()
                        uploader.uploadPhotoForPublication(publication)
                    }
                })
            }
            else {
                self.removeActivityIndicator()
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
                publication.photoData.photo = self.dataSource[0].userData as? UIImage
                
                FCModel.sharedInstance.addPublication(publication)
                FCModel.sharedInstance.addUserCreatedPublication(publication)
                FCModel.sharedInstance.deleteOldVersionsOfUserCreatedPublication(publication)
                
                if publication.photoData.photo != nil {
                    //send the photo
                    let uploader = FCPhotoFetcher()
                    uploader.uploadPhotoForPublication(publication)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if self.state == .EditPublication{
            
                        let publicationDetailsNavigationController = self.navigationController?.presentingViewController as? UINavigationController
                        let publicationDetailsTVC = publicationDetailsNavigationController?.viewControllers[0] as? FCPublicationDetailsTVC
                        publicationDetailsTVC?.publication = publication
                        publicationDetailsTVC?.reload()
                        
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                        
                        
            
                    }
                
                })
            }
                
            else {
                self.removeActivityIndicator()
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not post your event",aMessage: "try again later")
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func removeActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.activityIndicatorBlureView.removeFromSuperview()
            self.tableView.userInteractionEnabled = true
            self.activityIndicatorBlureView.alpha = 0
        })
    }
    
    func prepareParamsDictToSend() -> [String: AnyObject]{
        // 0.  Photo
        // 1.  Title
        // 2.  Address + latitude + longitude
        // 3.  Start date
        // 4.  End date
        // 5.  Type of collection
        // 6.  Subtitle (More info)

        var params = [String: AnyObject]()
        params[kPublicationTitleKey] = self.dataSource[1].userData as! String
        let addressDict = self.dataSource[2].userData as! [String: AnyObject]
        params[kPublicationAddressKey] = addressDict["adress"] as! String
        params[kPublicationlatitudeKey] = addressDict["Latitude"] as! Double
        params[kPublicationLongtitudeKey] = addressDict["longitude"] as! Double
        
        let startingDate = self.dataSource[3].userData as! NSDate
        let startingDateInterval = startingDate.timeIntervalSince1970
        let startingDateInt: Int = Int(startingDateInterval)
        params[kPublicationStartingDateKey] = startingDateInt as Int
        
        let endingDate = self.dataSource[4].userData as! NSDate
        let endingDateInterval = endingDate.timeIntervalSince1970
        let endingDateInt: Int = Int(endingDateInterval)
        params[kPublicationEndingDateKey] = endingDateInt as Int
        
        let typeOfCollectingDict = self.dataSource[5].userData as! [String : AnyObject]
        params[kPublicationContactInfoKey] = typeOfCollectingDict[kPublicationContactInfoKey]
        params[kPublicationTypeOfCollectingKey] = typeOfCollectingDict[kPublicationTypeOfCollectingKey] as! Int
        var subtitle = self.dataSource[6].userData as? String ?? ""
        if subtitle ==  "" { subtitle = " "}
        params[kPublicationSubTitleKey] = subtitle
        return params
    }

    
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


//===========================================================================
//   MARK: - Prepare Cell Data
//===========================================================================
extension  PublicationEditorTVC {

    func prepareDataSource() {
        // Sections Index
        // 0.  Photo
        // 1.  Title
        // 2.  Address + latitude + longitude
        // 3.  Start date
        // 4.  End date
        // 5.  Type of collection
        // 6.  Subtitle (More Info)
        
        var initialTitles = [kPublishImage, kPublishTitle, kPublishAddress, kPublishStartDate, kPublishEndDate, kPublishPhoneNumber, kPublishSubtitle]
        
        for index in 0...6 {
            
            var cellData = PublicationEditorTVCCellData()
            cellData.cellTitle = initialTitles[index]
            
            if self.state == .EditPublication {
                
                if let publication = self.publication {
                    
                    switch index {
                    
                    case 0:
                        //publication photo
                        if let photo = publication.photoData.photo {
                            
                            cellData.userData = photo
                            cellData.containsUserData = true
                            cellData.cellTitle = kPublishedImage
                        }

                    case 1:
                        //publication title
                        cellData.userData = publication.title!
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.title!
                        
                    case 2:
                        //publication address
                        let addressDict: [String: AnyObject] = ["adress":publication.address ,"Latitude":publication.coordinate.latitude, "longitude" : publication.coordinate.longitude]
                        cellData.userData = addressDict
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.address
                        
                    case 3:
                        //publication starting date
                        cellData.userData = publication.startingDate
                        cellData.containsUserData = true
                        cellData.cellTitle = kPublishStartDate
                        
                    case 4:
                        //publication ending date
                        cellData.userData = publication.endingDate
                        cellData.containsUserData = true
                        cellData.cellTitle = kPublishEndDate
                        
                    case 5:
                        //publication phone number (it was type of collecting)
                        cellData.cellTitle = publication.contactInfo!
                        cellData.containsUserData = true
                        
                        if publication.typeOfCollecting == .FreePickUp {
                            cellData.containsUserData = false
                            cellData.cellTitle = kPublishPhoneNumber
                            publication.typeOfCollecting = .ContactPublisher // Every publication has to have a phone number
                            
                        }
                        
                        let typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : publication.typeOfCollecting.rawValue , kPublicationContactInfoKey : publication.contactInfo!]
                        
                        cellData.userData = typeOfCollectingDict
                        
                        if publication.contactInfo! == "" {
                            cellData.containsUserData = false
                            cellData.cellTitle = kPublishPhoneNumber
                        }
                        
                    case 6:
                        //publication subTitle (More Info)
                        cellData.userData = publication.subtitle ?? ""
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.subtitle ?? kPublishSubtitle
                        
                    default:
                        break
                    }
                    
                }
            }
            else { // Create defaults for new empty publication
                print(">>> Create defaults for new empty publication")
                
                switch index {
                case 0:
                    //publication photo
                    cellData.containsUserData = true
                    
                case 3:
                    //publication starting date
                    cellData.userData = NSDate()
                    cellData.containsUserData = true
                    cellData.cellTitle = kPublishStartDate
                    
                case 4:
                    //publication ending date
                    cellData.userData = NSDate().dateByAddingTimeInterval(kTimeIntervalInSecondsToEndDate)
                    cellData.containsUserData = true
                    cellData.cellTitle = kPublishEndDate
                    
                case 5:
                    //phone number (it was publication type of collecting)
                    let typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : 2 , kPublicationContactInfoKey : ""]
                    cellData.userData = typeOfCollectingDict
                    cellData.containsUserData = false
                    cellData.cellTitle = kPublishPhoneNumber
                    
                default:
                    break
                }
            }
            self.dataSource.append(cellData)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.description)
    }
}

//===========================================================================
//   MARK: - Image Functions
//===========================================================================
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if info[UIImagePickerControllerEditedImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.updateCellDataWithImage(image)
        }
    }
    
    func updateCellDataWithImage(anImage: UIImage) {
        //update data source
        var cellData = PublicationEditorTVCCellData()
        cellData.containsUserData = true
        cellData.userData = anImage
        cellData.cellTitle = kPublishedImage
        //let section = self.selectedIndexPath!.section
        self.dataSource[0] = cellData
        checkIfReadyForPublish()
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
}

////===========================================================================
////   MARK: - Misc Functions
////===========================================================================
//
//extension PublicationEditorTVC {
//    func getTypeOfCollectingDict(#typeOfCollecting: Int, contactDetails: String) -> [String : AnyObject] {
//        return  [kPublicationTypeOfCollectingKey : typeOfCollecting , kPublicationContactInfoKey : contactDetails]
//    }
//}

//===========================================================================
//   MARK: - Protocols
//===========================================================================
protocol CellInfoDelegate :NSObjectProtocol{
    func updateData(data:PublicationEditorTVCCellData, section: Int)
    func closeDatePicker()
}


