//
//  FCArrivedToPublicationSpotVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

protocol FCOnSpotPublicationReportDelegate {
    func dismiss()
}


class FCArrivedToPublicationSpotVC: UIViewController {
    
    @IBOutlet weak var publicationTitleLable: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tookAllButton: UIButton!
    @IBOutlet weak var tookSomeButton: UIButton!
    @IBOutlet weak var nothingThereButton: UIButton!
    
    var publication: Publication?
    var delegate: FCOnSpotPublicationReportDelegate?    //FCMainTabBar
    
    func setup(aPublication: Publication) {
        
        self.publicationTitleLable.text = aPublication.title
        
        if aPublication.photoBinaryData != nil {
            self.imageView.image = UIImage(data: aPublication.photoBinaryData!)
        }
        else if aPublication.didTryToDownloadImage?.boolValue == false {
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(aPublication, completion: { (image) -> Void in
               
                if image != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = image
                        self.view.reloadInputViews()
                        self.view.setNeedsDisplay()
                    })
                }
            })
        }
        
        self.presentUserNotCloseToPublicationAlertIfNeeded()
    }
    
    @IBAction func tookAllAction(sender: AnyObject) {
        self.postOnSpotReportWithMessage(.TookAll)
    }
    
    @IBAction func tookSomeAction(sender: AnyObject) {
        self.postOnSpotReportWithMessage(.HasMore)
    }
    
    @IBAction func nothingThereAction(sender: AnyObject) {
        self.postOnSpotReportWithMessage(.NothingThere)
    }
    
    func postOnSpotReportWithMessage(message: FCOnSpotPublicationReportMessage) {
        
        let context = FCModel.dataController.managedObjectContext
        context.performBlock { () -> Void in
            
            let report = PublicationReport.reportForPublication(message.rawValue ,publication: self.publication!, context: context)
            FCModel.sharedInstance.foodCollectorWebServer.postReportforPublication(report)
            
        }
        
        self.delegate?.dismiss()
    }
    
    func cancelButtonAction(sender: AnyObject){
        self.delegate?.dismiss()
        GAController.sendAnalitics(kFAPublicationReportScreenName, action: "canceled report action", label: "user did not report", value: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonTitle = NSLocalizedString("Not Now",comment:"Navigation bar button title")
        let rightButton = UIBarButtonItem(title: buttonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "cancelButtonAction:")
        self.navigationItem.rightBarButtonItem = rightButton
        configureButton(self.tookAllButton)
        configureButton(self.tookSomeButton)
        configureButton(self.nothingThereButton)
        
        if let publication = self.publication {
            setup(publication)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAController.reportsAnalyticsForScreen(kFAPublicationReportScreenName)
    }
    
    func configureButton(button: UIButton) {
        
        button.layer.borderColor = UIColor.blueColor().CGColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
    }
    
    func presentUserNotCloseToPublicationAlertIfNeeded() {
        
        //let userLocation = FCModel.sharedInstance.userLocation
        let distanceFromPublication = self.publication?.distanceFromUserLocation
        
        if distanceFromPublication != nil && distanceFromPublication > 2000 {
            
            let title = NSLocalizedString("You are far from the event's location", comment:"")
            let message = NSLocalizedString("Please report only after you have visited the event's location", comment:"")
            
            let alertController = UIAlertController(title: title, message:message, preferredStyle: .Alert)
            let dissmissAction = UIAlertAction(title:NSLocalizedString("Cool", comment:"alert dissmiss button title"), style: .Cancel) { (action) in
                alertController.dismissViewControllerAnimated(true , completion: nil)
            }

            alertController.addAction(dissmissAction)
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
            
        }

    }
}