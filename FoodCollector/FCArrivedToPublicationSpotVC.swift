//
//  FCArrivedToPublicationSpotVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

public struct FCOnSpotPublicationReport {
    
    var onSpotPublicationReportMessage:FCOnSpotPublicationReportMessage
    var date:NSDate
}

enum FCOnSpotPublicationReportMessage: Int {
    
    case NothingThere = 5
    case TookAll = 3
    case HasMore = 1
    
}


class FCArrivedToPublicationSpotVC: UIViewController {
    
    @IBOutlet weak var publicationTitleLable: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tookAllButton: UIButton!
    @IBOutlet weak var tookSomeButton: UIButton!
    @IBOutlet weak var nothingThereButton: UIButton!

    var publication: FCPublication?
       

    func setup(aPublication: FCPublication) {
        
        self.publicationTitleLable.text = aPublication.title
        
        if aPublication.photoData.photo != nil {
            self.imageView.image = aPublication.photoData.photo!
        }
        else if !aPublication.photoData.didTryToDonwloadImage {
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(aPublication, completion: { (image) -> Void in
                aPublication.photoData.photo = image
                aPublication.photoData.didTryToDonwloadImage = true
                if let theImage = image {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = image
                        self.view.reloadInputViews()
                        self.view.setNeedsDisplay()
                    })
                }
            })
        }
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

    @IBAction func dissmissAction(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postOnSpotReportWithMessage(message: FCOnSpotPublicationReportMessage) {
        
        let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: message, date: NSDate())
    
        FCModel.sharedInstance.foodCollectorWebServer.reportArrivedPublication(self.publication!, withReport: report)
        
        self.dissmissAction(self)
    }
    
    func cancelButtonAction(sender: AnyObject){
        self.dissmissAction(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonTitle = "לא עכשיו"
        let rightButton = UIBarButtonItem(title: buttonTitle, style: UIBarButtonItemStyle.Done, target: self, action: "cancelButtonAction:")
        self.navigationItem.rightBarButtonItem = rightButton
        configureButton(self.tookAllButton)
        configureButton(self.tookSomeButton)
        configureButton(self.nothingThereButton)
        
        if let publication = self.publication {
            setup(publication)
        }
    }
    
    func configureButton(button: UIButton) {
       
        button.layer.borderColor = UIColor.blueColor().CGColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
    }
}