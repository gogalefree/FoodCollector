//
//  FCCollectorRootVC+.swift
//  FoodCollector
//
//  Created by Guy Freedman on 29/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import Foundation
import UIKit

extension FCCollectorRootVC: FetchedDataNotificationViewDelegate {
    
    func presentNotificationsFromWebFetch() {
        
        let padding: CGFloat = 5
//        let viewHeigt :CGFloat = 129
//        let viewWidth :CGFloat = 320
        let hiddenOrigin = CGPointMake(0, -300)
        var visibleOrigin = CGPointMake(0, 82)

        
        let views = FetchedDataNotificationsController.shared.notificationViews
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
         
            for notificationView in views {
             
                
                notificationView.frame.origin = hiddenOrigin
                notificationView.delegate = self
                notificationView.visibleOrigin = visibleOrigin
                self.view.addSubview(notificationView)
                self.view.bringSubviewToFront(notificationView)
                visibleOrigin.y += padding
            }
            
            self.animateNotificationsFromWebFetch(views)
        }
    }
    
    func animateNotificationsFromWebFetch(views : [FetchedDataNotificationView]) {
        
        for notificationView in views {
            
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                
                notificationView.frame.origin = notificationView.visibleOrigin
                
            }, completion: nil)
        }
    }
    
    //MARK: FetchedNotificationViewDelegate
    
    func presentPublicationFromNotificationView(notificationView: FetchedDataNotificationView) {
        
        let publication = notificationView.notification?.publication
        self.presentPublicationDetailsTVC(publication!)
        self.dissmissNotificationView(notificationView)
    }
    
    func dissmissNotificationView(notificationView: FetchedDataNotificationView) {
        
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: { () -> Void in
            
            notificationView.alpha = 0
            
            }) { (_) -> Void in
                
                notificationView.removeFromSuperview()
        }
    }

    
}