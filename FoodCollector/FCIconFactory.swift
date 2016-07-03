//
//  FCIconFactory.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/1/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCIconFactory: NSObject {
    
//    class func smallIconForPublication(publication: FCPublication) -> UIImage {
//        
//        var icon: UIImage
//        
//        switch publication.countOfRegisteredUsers {
//            
//        case 0...1:
//           icon = self.greenImage()
//            
//        case 2...4:
//            icon = self.orangeImage()
//            
//        default:
//            icon = self.redImage()
//        }
//        
//        return icon
//    }
//    
//    class func greenImage() -> UIImage {
//        
//         let icon = UIImage(named: "Pin-Whole")!
//        return icon
//    }
//    
//    class func orangeImage() -> UIImage{
//        
//        let icon = UIImage(named: "Pin-Half")!
//        return icon
//    }
//    
//    class func redImage() -> UIImage {
//        
//        let icon = UIImage(named: "Pin-Few")!
//        return icon
//    }
    
    class func publicationsTableIcon() -> UIImage {
    
        let icon = UIImage(named: "Pin_Map_Marker")!
        
//        switch publication.countOfRegisteredUsers {
//            
//        case 0...1:
//            icon = UIImage(named: "Pin-Table-Whole")!
//            
//        case 2...4:
//            icon = UIImage(named: "Pin-Table-Half")!
//            
//        default:
//            icon = UIImage(named: "Pin-Table-Few")!
//        }
//        
        return icon
    }
    
    class func typeOfPublicationIcon(publication: Publication) -> UIImage {
        // price is optional. If it is nil, than the publication is free.
        // If price is not nil and it is > 0, than the publication is NOT free.
        switch (publication.price, publication.audianceID) {
        case let (price, aID) where price?.intValue > 0 && aID > 0:
            // publication is not free and privet
            return UIImage(named: "GroupShareIconNotFree")!
            
        case let (price, aID) where price?.intValue > 0 && aID == 0:
            // publication is not free and public
            return UIImage(named: "PublicShareIconNotFree")!
            
        case let (nil, aID) where aID > 0:
            // publication is free (because it is optional and it is nil) and privet
            return UIImage(named: "GroupShareIcon")!
            
        default:
            // publication is free and public
            return UIImage(named: "PublicShareIcon")!
        }
    }
    
    class func typeOfPublicationIconWhite(publication: Publication) -> UIImage {
        
        var icon = UIImage(named: "AudienceIconPublic")!
        
        if publication.audianceID > 0 {
            icon = UIImage(named: "AudienceIconGroup")!
        }
        
        return icon
    }
    
    class func publicationDetailsReportIcon(report: PublicationReport) -> UIImage {
        
        var icon: UIImage
        
        switch report.report!.integerValue {
            
        case 1:
            icon = UIImage(named: "Pin-Table-Whole")!
            
        case 3:
            icon = UIImage(named: "Pin-Table-Half")!
            
        default:
            icon = UIImage(named: "Pin-Table-Few")!
        }
        
        return icon
    }
    
    class func backBGImage() -> UIImage? {
        
        var barButtonBGImageName = "BackArrowLeftBG"
        var edgeInsets = UIEdgeInsetsMake(1, 30, 1, 1)
        
        if UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft {
            barButtonBGImageName = "BackArrowRightBG"
            edgeInsets = UIEdgeInsetsMake(1, 1, 1, 30)
        }
        
        let barButtonBGImage = UIImage(named:barButtonBGImageName)?.resizableImageWithCapInsets(edgeInsets)
        
        return barButtonBGImage
    }
}
