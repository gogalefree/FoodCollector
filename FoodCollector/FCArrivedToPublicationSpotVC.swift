//
//  FCArrivedToPublicationSpotVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/7/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

protocol FCOnSpotPublicationReportDelegate {
    func dismiss(report: PublicationReport?)
}


class FCArrivedToPublicationSpotVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var whiteBGTransparentView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var publicationTitleLabel: UILabel!
    @IBOutlet weak var pleaseReportTitleLabel: UILabel!
    @IBOutlet weak var reportMessageTableView: UITableView!
    @IBOutlet weak var ratingView: ArrivedToSpotRatingsView!
    var shadowPath :UIBezierPath!
    
    var reportMessage: FCOnSpotPublicationReportMessage? = nil
    

    var publication: Publication?
    var delegate: FCOnSpotPublicationReportDelegate?    //FCMainTabBar
    
    //MARK: Table view Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("arrivedToSpotCell", forIndexPath: indexPath) as! ArrivedToSpotCell
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        switch indexPath.row {
        case 0:
            reportMessage = .HasMore
        case 1:
            reportMessage = .TookAll
        case 2:
            reportMessage = .NothingThere
        default:
            reportMessage = nil
        }
    }
    
    func setup(aPublication: Publication) {
        
        self.publicationTitleLabel.text = aPublication.title
        self.presentUserNotCloseToPublicationAlertIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shadowPath == nil {
            shadowPath = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: 5)
            contentView.layer.masksToBounds = false
            self.contentView.layer.shadowColor = UIColor.blackColor().CGColor
            self.contentView.layer.shadowOffset = CGSizeMake(0, 0)
            self.contentView.layer.shadowOpacity = 0.5
            self.contentView.layer.shadowPath = shadowPath.CGPath
            self.contentView.layer.cornerRadius = 5
        }
    }
    @IBAction func postReport(sender: AnyObject) {
  
        let ratings = self.ratingView.ratings
        print("ratings is \(ratings)")

        guard let message = self.reportMessage?.rawValue else {return}
        if message != 1 && message != 3 && message != 5 {return}
        
        //make the report
        let moc = FCModel.sharedInstance.dataController.managedObjectContext
        let report = PublicationReport.reportForPublication(message, publication: publication!, rating: ratings,context: moc)
        
        //pass it back to publication details tvc
        self.delegate?.dismiss(report)
        
        //post report to server
        FCModel.sharedInstance.foodCollectorWebServer.postReportforPublication(report)
        
        //post ratings to server
        
        
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
    
        self.delegate?.dismiss(nil)
        GAController.sendAnalitics(kFAPublicationReportScreenName, action: "canceled report action", label: "user did not report", value: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let publication = self.publication {
            setup(publication)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAController.reportsAnalyticsForScreen(kFAPublicationReportScreenName)
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