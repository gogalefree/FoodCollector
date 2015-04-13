//
//  FCPublishRootVCCustomCollectionViewCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 17/11/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import Foundation

class FCPublishRootVCCustomCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var FCPublisherEventImage: UIImageView!
    @IBOutlet weak var FCPublisherEventStatusIcon: UIImageView!
    
    @IBOutlet weak var FCPublisherEventTitle: UILabel!
    @IBOutlet weak var FCPublisherEventStatus: UILabel!
    

    var publication: FCPublication? {
        didSet {
            
            if let publication = self.publication {
                
                var status = ""
                var statusImg : UIImage
                let locDateString = FCDateFunctions.localizedDateStringShortStyle(publication.endingDate)
                
                if FCDateFunctions.PublicationDidExpired(publication.endingDate){
                    status = String.localizedStringWithFormat("הסתיים" , "the puclication is off the air")
                    statusImg = UIImage(named: "Red-dot")!
                    publication.isOnAir = false
                }
                else {
                    status = String.localizedStringWithFormat("פעיל \(locDateString)" , "the publication is active untill this date")
                    statusImg = UIImage(named: "Green-dot")!
                    
                    if  !publication.isOnAir {
                        status = String.localizedStringWithFormat("לא פעיל" , "the publication is not active beacause it was taken off air")
                        statusImg = UIImage(named: "Red-dot")!

                    }
                }
                
                self.FCPublisherEventTitle.text = publication.title
                self.FCPublisherEventStatus.text = status
                self.FCPublisherEventStatusIcon.image = statusImg
                
                if publication.photoData.photo != nil {
                    self.FCPublisherEventImage.image = publication.photoData.photo!
                }
                else if !publication.photoData.didTryToDonwloadImage {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        
                        let fetcher = FCPhotoFetcher()
                        fetcher.fetchPhotoForPublication(publication,
                            completion: { (image) -> Void in
                                
                                if publication.photoData.photo != nil {
        
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        
                                        UIView.animateWithDuration(0.4, animations: { () -> Void in
                                            self.FCPublisherEventImage.alpha = 0
                                            self.FCPublisherEventImage.image = publication.photoData.photo
                                            self.FCPublisherEventImage.alpha = 1
                                        })
                                    })
                                }
                        })
                    })
                }
            }
        }
    }
    
    override func prepareForReuse() {
        self.FCPublisherEventImage.image = UIImage(named: "NoPhoto-Placeholder")
    }
}
