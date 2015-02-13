//
//  FCTableViewAnimator.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/14/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import Foundation
import UIKit

class FCTableViewAnimator: NSObject {

    class func animateCell(cell:UITableViewCell , sender: UIViewController) {
    
        let finalRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.bounds.width, cell.bounds.height);
        
        cell.frame = CGRectMake(cell.frame.origin.x,
            sender.view.frame.size.height,
            cell.bounds.width, cell.bounds.height)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
          cell.frame = finalRect
        }, completion: nil)
    }
        
        
//      
//    [UIView beginAnimations:nil  context:NULL];
//    [UIView setAnimationDuration:0.5];
//    [cell setFrame:final];
//    [UIView commitAnimations];
//    

}
