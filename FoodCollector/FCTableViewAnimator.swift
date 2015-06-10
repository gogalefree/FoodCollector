//
//  FCTableViewAnimator.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/14/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import Foundation
import UIKit

class FCTableViewAnimator: NSObject {

    class func animateCell(cell:UITableViewCell , sender: UIViewController) {
    
        let finalRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.bounds.width, cell.bounds.height);
        
        cell.frame = CGRectMake(cell.frame.origin.x,
            sender.view.bounds.size.height,
            cell.bounds.width, cell.bounds.height)
      //  cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2)
            
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
          cell.frame = finalRect
        //    cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)

        }, completion: nil)
    }
    
    class func animateCollectionViewCell(cell: UICollectionViewCell , sender: UIView) {
        
        let finalRect = cell.frame //CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.bounds.width, cell.bounds.height);
        
        cell.frame = CGRectMake(cell.frame.origin.x,
            sender.bounds.size.height,
            cell.bounds.width, cell.bounds.height)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            cell.frame = finalRect            
            }, completion: nil)
    }
        

}
