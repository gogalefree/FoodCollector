//
//  DragView.swift
//  SettingXMP
//
//  Created by Guy Freedman on 09/03/2016.
//  Copyright © 2016 TPApps. All rights reserved.
//

import UIKit

protocol DragViewDelegate: NSObjectProtocol {

    func didDragWithDistance(distance: CGFloat)
    func dragDidStop()
}

class DragView: UIView {

    var dragValue: CGFloat = 0
    var startLocation: CGPoint = CGPointZero
    
    var panRecognizer  :UIPanGestureRecognizer!
    
    var delegate: DragViewDelegate!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if panRecognizer == nil {
            
            panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
            self.addGestureRecognizer(panRecognizer)
           
            
        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if (sender.state == .Began) {
            startLocation = sender.locationInView(self)
        }
            
        else if (sender.state == .Changed) {
            let stopLocation = sender.locationInView(self)
            let dx = stopLocation.x - startLocation.x
            delegate?.didDragWithDistance(dx)
        }
        
        else if sender.state == .Ended {
            delegate?.dragDidStop()
        }
        
    }
    
    
}
