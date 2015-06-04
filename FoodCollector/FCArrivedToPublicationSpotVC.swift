//
//  FCArrivedToPublicationSpotVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import UIKit

protocol FCOnSpotPublicationReportDelegate {
    func dismiss()
}

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
    var delegate: FCOnSpotPublicationReportDelegate?    //FCMainTabBar
    
    func setup(aPublication: FCPublication) {
        
        self.publicationTitleLable.text = aPublication.title
        
        if aPublication.photoData.photo != nil {
            self.imageView.image = aPublication.photoData.photo!
        }
        else if !aPublication.photoData.didTryToDonwloadImage {
            let fetcher = FCPhotoFetcher()
            fetcher.fetchPhotoForPublication(aPublication, completion: { (image) -> Void in
               
                if aPublication.photoData.photo != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = aPublication.photoData.photo
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
    
    func postOnSpotReportWithMessage(message: FCOnSpotPublicationReportMessage) {
        
        let report = FCOnSpotPublicationReport(onSpotPublicationReportMessage: message, date: NSDate())
        
        FCModel.sharedInstance.foodCollectorWebServer.reportArrivedPublication(self.publication!, withReport: report)
        self.delegate?.dismiss()
    }
    
    func cancelButtonAction(sender: AnyObject){
        self.delegate?.dismiss()
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
        button.layer.borderWidth = 0.5
    }
}