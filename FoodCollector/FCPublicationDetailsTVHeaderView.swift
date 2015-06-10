//
//  FCPublicationDetailsTVHeaderView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/27/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationDetailsTVHeaderView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var publication: FCPublication? {
        didSet {
            updatePhoto()
        }
    }
    
    private let kTableHeaderCutAway: CGFloat = 60
    var headerMaskLayer: CAShapeLayer!

    override func awakeFromNib() {
        super.awakeFromNib()
        headerMaskLayer = CAShapeLayer()
        //headerMaskLayer.fillColor = UIColor.greenColor().CGColor
        self.layer.mask = headerMaskLayer
    }
    
    func updateCutAway(headerRect: CGRect) {
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height - kTableHeaderCutAway))
        path.addLineToPoint(CGPoint(x: 0, y: headerRect.height))
        headerMaskLayer?.path = path.CGPath
    }
    
    func updatePhoto() {
        
        if let publication = self.publication {
            if let photo = publication.photoData.photo {
                self.imageView.animateToAlphaWithSpring(0.2, alpha: 0)
                self.imageView.image = photo
                self.imageView.animateToAlphaWithSpring(0.4, alpha: 1)
            }
        }
    }
    
//    override init() {
//        UIView.loadFromNibNamed("", bundle: nil)
//        super.init()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
