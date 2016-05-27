//
//  PublicationEditorTVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 06/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

let kPublishButtonTitle = NSLocalizedString("Publish", comment:"Title for a button")
let kPublishTitle = NSLocalizedString("What are you sharing?", comment:"Add title for a new event")
let kPublishAddress = NSLocalizedString("Event location", comment:"Add address for a new event")
let kPublishPhoneNumber = NSLocalizedString("What's your phone number?", comment:"Add phone number for a new event")
let kPublishStartDate = NSLocalizedString("Pickup starts:", comment:"Add start date for a new event")
let kPublishEndDate = NSLocalizedString("Pickup ends:", comment:"Add end date for a new event")
let kPublishImage = NSLocalizedString("Start sharing by adding a photo of the item you wish to share.", comment:"Add image for a new event")
let kPublishedImage = NSLocalizedString("Selected picture", comment:"This is the image you have selected label")
let kPublishSubtitle = NSLocalizedString("Additional details", comment:"Add subitle for a new event")
let kPublishAudiance = NSLocalizedString("Share With:", comment:"Add share type (public/privet for a new event")



let kAddDefaultHoursToStartDate:Double = 48 // Amount of hours to add to the start date so that we will have an End date for new publication only!
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

public enum TypeOfCollecting: Int {
    
    case FreePickUp = 1
    case ContactPublisher = 2
    
}


class PublicationEditorTVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CellInfoDelegate {
    
    var publication:Publication?
    var state = PublicationEditorTVCState.CreateNewPublication
    var dataSource = [PublicationEditorTVCCellData]()
    lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    var selectedIndexPath: NSIndexPath?
    var publishButtonEnabled = false
    lazy var activityIndicatorBlureView = UIVisualEffectView()
    
    let defaultRowHeigt = CGFloat(45)
    let pictureRowHeigt = CGFloat(165)
    
    var showStartDatePickerCell = false
    var showEndDatePickerCell = false

    func setupWithState(initialState: PublicationEditorTVCState, publication: Publication?) {
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
        
        let barButton = UIBarButtonItem(title: kBackButtonTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(PublicationEditorTVC.backButtonAction))
        barButton.setBackgroundImage(FCIconFactory.backBGImage(), forState: .Normal, barMetrics: .Default)
        self.navigationItem.leftBarButtonItem = barButton

        tableView.registerNib(UINib(nibName: "PublicationEditorTVCImageCustomCell", bundle: nil), forCellReuseIdentifier: "imageCustomCell")
        tableView.registerNib(UINib(nibName: "PublicationEditorTVCTextFieldCustomCell", bundle: nil), forCellReuseIdentifier: "textFieldCustomCell")
        tableView.registerNib(UINib(nibName: "PublicationEditorTVCOnlyLabelCustomCell", bundle: nil), forCellReuseIdentifier: "onlyLabelCustomCell")
        tableView.registerNib(UINib(nibName: "PublicationEditorTVCAudianceCustomCell", bundle: nil), forCellReuseIdentifier: "audianceCustomCell")
        tableView.registerNib(UINib(nibName: "PublicationEditorTVCMoreInfoCustomCell", bundle: nil), forCellReuseIdentifier: "moreInfoCustomCell")

        
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0) //(top, left, bottom, right)
        tableView.preservesSuperviewLayoutMargins = false
        tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0) //(top, left, bottom, right)
        
        // To hide the empty cells set a zero size table footer view.
        // Because the table thinks there is a footer to show, it doesn't display any
        // cells beyond those you explicitly asked for.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        

    }
    
    func backButtonAction() {
        //self.popViewController()
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    // Section 3 - Audiance (Public / Group)
    //    Cell 0 - Label
    
    // Section 4 - More Detials
    //    Cell 0 - Text field
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0: // Image Section
            return pictureRowHeigt
        case 4: // More Info Section
            return 100
        default:
            return defaultRowHeigt
        }
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

        case 3: // Audiance (Public / Group) Section
            let audianceCell = tableView.dequeueReusableCellWithIdentifier("audianceCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCAudianceCustomCell
            audianceCell.cellData = self.dataSource[indexPath.section]
            
            return audianceCell

        case 4: // More Info Section
            let moreInfoCell = tableView.dequeueReusableCellWithIdentifier("moreInfoCustomCell", forIndexPath: indexPath) as! PublicationEditorTVCMoreInfoCustomCell
            moreInfoCell.cellData = self.dataSource[indexPath.section]
            moreInfoCell.section = indexPath.section
            moreInfoCell.delegate = self
            moreInfoCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return moreInfoCell
        
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
            self.performSegueWithIdentifier("showPublicationAdressEditor", sender: indexPath.row)
            
        case 3: // Audiance (Public / Group) Section
            self.performSegueWithIdentifier("showPublicationAudianceSelection", sender: indexPath.row)
        
        default:
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

    
    func updateData(data:PublicationEditorTVCCellData, section: Int){
        print("updateData")
        dataSource[section] = data
        
        // If it's not the image cell (section=0), reload section.
        if section != 0 {tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)}
        
        checkIfReadyForPublish()
    }


//===========================================================================
//   MARK: - Navigation Functions
//===========================================================================

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let section = self.selectedIndexPath!.section
        let cellData = self.dataSource[section]
        
        if (segue.identifier == "showPublicationAudianceSelection") {
            let audianceSelectionTVC = segue.destinationViewController as! PublicationAudianceSelectionTVC
            audianceSelectionTVC.cellData = cellData
            audianceSelectionTVC.section = section
        }
    }
    
    
    
    @IBAction func unwindFromAddressEditorVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as! FCPublishAddressEditorVC
        let cellData = sourceVC.cellData
        let section = selectedIndexPath!.section
        self.dataSource[section] = cellData
        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
        checkIfReadyForPublish()
    }
    
    @IBAction func unwindFromAudianceSelectionTVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.sourceViewController as! PublicationAudianceSelectionTVC
        if let cellData = sourceVC.cellData {
            let section = selectedIndexPath!.section
            self.dataSource[section] = cellData
            self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath!], withRowAnimation: .Automatic)
            checkIfReadyForPublish()
        }
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: kPublishButtonTitle, style: .Done, target: self, action: #selector(PublicationEditorTVC.publish))
        setTopRightButtonStatus()
    }
    
    func setTopRightButtonStatus(){
        self.navigationItem.rightBarButtonItem!.enabled = publishButtonEnabled
    }
    
    func addPictureButton(){
        let screenWidth = UIScreen.mainScreen().bounds.width
        let buttonWidth = CGFloat(54)
        let buttonHeight = CGFloat(54)
        let paddingFromEdge = CGFloat(40)
        
        let image = UIImage(named: "CameraIcon") as UIImage?
        let auxiliaryView = UIView(frame: CGRectMake(0, 0, screenWidth, pictureRowHeigt))
        
        // When I try to position the button (using constraints) relative to it’s superview (UITableView),
        // the trailing position is not in the place it should be. After some investigation, I still don’t
        // know why. Therefore, I created an auxiliary view to act as the container for the button.
        // The auxiliaryView helps to position the button using the proper constraints.
        
        let button   = UIButton(type: UIButtonType.Custom)
        //button.backgroundColor = kNavBarBlueColor //UIColor(red: 0.0, green: 128/255, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = buttonWidth / 2
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(PublicationEditorTVC.pictureButtonTouched(_:)), forControlEvents:.TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(
            item: button,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Width,
            multiplier: 1.0,
            constant: buttonWidth)
        
        let heightConstraint = NSLayoutConstraint(
            item: button,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: buttonHeight)
        
        let trailingConstraint = NSLayoutConstraint(
            item: auxiliaryView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: button,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: paddingFromEdge)
        
        let topConstraint = NSLayoutConstraint(
            item: button,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: auxiliaryView,
            attribute: .Top,
            multiplier: 1.0,
            constant: CGFloat(pictureRowHeigt-(buttonHeight/2)))
        
        auxiliaryView.addSubview(button)
        auxiliaryView.addConstraints([widthConstraint, heightConstraint, trailingConstraint, topConstraint])
        self.view.addSubview(auxiliaryView)
    }
    
    func pictureButtonTouched(object : UIButton) {
        presentImagePickerActionSheet()
    }
    

//===========================================================================
//   MARK: - Publish buttons logic
//===========================================================================
    
    private func checkIfReadyForPublish(){
        var containsData = true
        
        for index in 0...3 {
            
            let cellData = self.dataSource[index]
            if !cellData.containsUserData {
                containsData = false
                break
            }
        }
        
        self.publishButtonEnabled = containsData
    
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
        let center = CGPointMake(DeviceData.screenWidth() / 2, DeviceData.screenHight() / 2 + offset )
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
        print("publishNewCreatedPublication")
        var newParams = self.prepareParamsDictToSend()
        
        let context = FCModel.sharedInstance.dataController.managedObjectContext
        let publication = NSEntityDescription.insertNewObjectForEntityForName(kPublicationEntity, inManagedObjectContext: context) as! Publication
        publication.isUserCreatedPublication = true
        
        print("publishNewCreatedPublication 1")
        
        let imageData = UIImageJPEGRepresentation(self.dataSource[0].userData as! UIImage, 0.5)
        publication.photoBinaryData = imageData
        publication.didTryToDownloadImage = true
        
        print("publishNewCreatedPublication 2")
        FCModel.sharedInstance.foodCollectorWebServer.postNewCreatedPublication(newParams, completion: {
            (success: Bool, params: [String: AnyObject]) -> () in
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    context.performBlock({ () -> Void in
                        newParams[kPublicationUniqueIdKey] = params[kPublicationUniqueIdKey]
                        newParams[kPublicationVersionKey] = params[kPublicationVersionKey]
                        publication.updateAfterUserCreation(newParams, context: context)
                        
                        //add the new publication
                        FCModel.sharedInstance.addPublication(publication)
                        
                        //add user created publication
                        FCModel.sharedInstance.addUserCreatedPublication(publication)
                        
                        if publication.photoBinaryData != nil {
                            //send the photo
                            let uploader = FCPhotoFetcher()
                            uploader.uploadPhotoForPublication(publication)
                        }

                    })
                })
            }
            else {
                print("publishNewCreatedPublication 10")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("publishNewCreatedPublication 11")
                    self.removeActivityIndicator()
                    let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not post your event", aMessage: "try again later")
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                    print("publishNewCreatedPublication 12")
                    publication.updateAfterUserCreation(newParams, context: context)
                    publication.didInformServer = false
                    
                    if publication.photoBinaryData != nil {
                        print("publishNewCreatedPublication 13")
                        //send the photo
                        let uploader = FCPhotoFetcher()
                        uploader.uploadPhotoForPublication(publication)
                        print("publishNewCreatedPublication 14")
                    }
                })
                print("publishNewCreatedPublication 15")
            }
        })
        print("publishNewCreatedPublication 16")
    }
    
    func publishEdidtedPublication() {
        
        let context = FCModel.sharedInstance.dataController.managedObjectContext
        
        var params = self.prepareParamsDictToSend()
        params[kPublicationUniqueIdKey] = self.publication?.uniqueId?.integerValue
        params[kPublicationVersionKey] = (self.publication?.version?.integerValue ?? 0) + 1
        self.publication?.updateAfterUserCreation(params, context: context)
        
        FCModel.sharedInstance.foodCollectorWebServer.postEditedPublication(params, publication: self.publication!) { (success, version) -> () in
            
            if success {
                
                //delete old image
                let fetcher = FCPhotoFetcher()
                fetcher.deletePhotoForPublication(self.publication!)
                
                let image = self.dataSource[0].userData as? UIImage
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    context.performBlock({ () -> Void in
                    
                        self.publication?.version = NSNumber(integer: version)
                        self.publication?.isOnAir = true
                        self.publication?.isUserCreatedPublication = true
                        if image != nil {
                          
                            self.publication?.photoBinaryData = UIImageJPEGRepresentation(image!, 1)
                            let uploader = FCPhotoFetcher()
                            uploader.uploadPhotoForPublication(self.publication!)
                            
                        }
                    })
                    
                    if self.state == .EditPublication{
            
                        let publicationDetailsNavigationController = self.navigationController?.presentingViewController as? UINavigationController
                        let publicationDetailsTVC = publicationDetailsNavigationController?.viewControllers[0] as? PublicationDetailsVC
                        publicationDetailsTVC?.publication = self.publication
                        publicationDetailsTVC?.reload()
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
                
            else {
                self.removeActivityIndicator()
                let alert = FCAlertsHandler.sharedInstance.alertWithDissmissButton("could not post your event",aMessage: "try again later")
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                
                self.publication?.didInformServer = false
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
        // 3.  Audiance (Public / Group)
        // 4.  More Info (used to be Subtitle)

        var params = [String: AnyObject]()
        
        // Title
        params[kPublicationTitleKey] = self.dataSource[1].userData as! String
        
        // Address + latitude + longitude
        let addressDict = self.dataSource[2].userData as! [String: AnyObject]
        params[kPublicationAddressKey] = addressDict["adress"] as! String
        params[kPublicationlatitudeKey] = addressDict["Latitude"] as! Double
        params[kPublicationLongtitudeKey] = addressDict["longitude"] as! Double
        
        // Audiance (Public / Group)
        params[kPublicationAudianceKey] = self.dataSource[3].userData as! Int
        
        // Start Date
        let startingDate = NSDate()
        let startingDateInterval = startingDate.timeIntervalSince1970
        let startingDateInt: Int = Int(startingDateInterval)
        params[kPublicationStartingDateKey] = startingDateInt as Int
        
        // End Date
        let endingDate = startingDate.dateByAddingTimeInterval(kTimeIntervalInSecondsToEndDate)
        let endingDateInterval = endingDate.timeIntervalSince1970
        let endingDateInt: Int = Int(endingDateInterval)
        params[kPublicationEndingDateKey] = endingDateInt as Int
        
        // Type of collection
        params[kPublicationContactInfoKey] = User.sharedInstance.userPhoneNumber
        params[kPublicationTypeOfCollectingKey] = 2
        
        // More Info (used to be Subtitle)
        var subtitle = self.dataSource[4].userData as? String ?? ""
        if subtitle ==  "" { subtitle = " "}
        params[kPublicationSubTitleKey] = subtitle
        
        return params
    }

    
    func fetchPhotoIfNeeded() {
        
        if let publication = self.publication {
            // && !publication.didTryToDownloadImage!.boolValue//we dont check for now
            if (publication.photoBinaryData == nil) {
                let photoFetcher = FCPhotoFetcher()
                photoFetcher.fetchPhotoForPublication(publication, completion: { (image) -> Void in
                    var cellData = self.dataSource[0]
                    if let photo = image {
                        cellData.userData = photo
                        cellData.containsUserData = true
                        self.dataSource[0] = cellData
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
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
        // Sections Index -- NEW
        // 0.  Photo
        // 1.  Title
        // 2.  Address + latitude + longitude
        // 3.  Audiance (Public / Group)
        // 4.  More Info (used to be Subtitle)
        
        var initialTitles = [kPublishImage, kPublishTitle, kPublishAddress, kPublishAudiance, kPublishSubtitle]
        
        for index in 0...4 {
            
            var cellData = PublicationEditorTVCCellData()
            cellData.cellTitle = initialTitles[index]
            
            if self.state == .EditPublication {
                
                if let publication = self.publication {
                    
                    switch index {
                    
                    case 0:
                        //publication photo
                        if let data = publication.photoBinaryData {
                            
                            cellData.userData = UIImage(data: data)!
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
                        let addressDict: [String: AnyObject] = ["adress":publication.address! ,"Latitude":publication.coordinate.latitude, "longitude" : publication.coordinate.longitude]
                        cellData.userData = addressDict
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.address!
                        
                    case 3:
                        //publication audiance (public / group)
                        if let groupID = publication.audiance?.integerValue {
                            cellData.userData = groupID
                        }
                        else {
                            cellData.userData = 0
                        }
                        cellData.containsUserData = true
                        cellData.cellTitle = kPublishAudiance
                    
                    case 4:
                        //publication subTitle (More Info)
                        cellData.userData = publication.subtitle ?? ""
                        cellData.containsUserData = true
                        cellData.cellTitle = publication.subtitle ?? kPublishSubtitle
                                          cellData.containsUserData = true
                        
                    default:
                        break
                    }
                    
                }
            }
            else { // Create defaults for new empty publication
                print(">>> Create defaults for new empty publication")
                
                switch index {
                case 3:
                    //publication audiance (public / group)
                    cellData.userData = 0
                    cellData.containsUserData = true
                    cellData.cellTitle = kPublishAudiance
                    
                default:
                    break
                }
            }
            self.dataSource.append(cellData)
        }
    }
}

//===========================================================================
//   MARK: - Image Functions
//===========================================================================
extension PublicationEditorTVC {
    
    func presentImagePickerActionSheet() {
        
        let actionSheet = UIAlertController(title: "", message:"", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let dissmissAction = UIAlertAction(title:kCancelButtonTitle, style: .Cancel) { (action) in
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let cameraAction = UIAlertAction(title:NSLocalizedString("Camera", comment:"camera button title "), style: UIAlertActionStyle.Default) { (action) in
            self.presentImagePickerController(.Camera)
            actionSheet.dismissViewControllerAnimated(true , completion: nil)
        }
        
        let photoLibraryAction = UIAlertAction(title:NSLocalizedString("Library", comment:"photo library button title"), style: UIAlertActionStyle.Default) { (action) in
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
    
    final func dismissVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
}


