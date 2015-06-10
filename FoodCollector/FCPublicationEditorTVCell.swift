//
//  FCPublicationEditorTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/13/15.
//  Copyright (c) 2015 UPP Project. All rights reserved.
//

import UIKit

class FCPublicationEditorTVCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var  photoImageView: UIImageView!
    var indexPath: NSIndexPath?
    var shouldEnableTakeOffAirButton = false
    var shouldEnablePublishButton = false
    
    var cellData: FCPublicationEditorTVCCellData? {
       
        didSet {
            
            if let cellData = self.cellData {
                
                self.titleLabel.text = cellData.cellTitle
                
                if let indexpath = self.indexPath {
                    
                    
                    switch indexpath.section {
                        
                    case 6:
                        //photo cell
                        if  cellData.containsUserData &&
                            cellData.userData is UIImage {
                            configurePhotoState()
                            }
                        
                    case 7:
                        //take off air cell
                        if !self.shouldEnableTakeOffAirButton {
                        configureTextLableWithColor(UIColor.lightGrayColor(), textAllignment: .Center)
                        self.userInteractionEnabled = false
                        }
                        else {
                            configureTextLableWithColor(UIColor.redColor(), textAllignment: .Center)
                            self.userInteractionEnabled = true
                        }
                        
                    case 8:
                        //publish cell
                        if !self.shouldEnablePublishButton {
                            configureTextLableWithColor(UIColor.lightGrayColor(), textAllignment: .Center)
                            self.userInteractionEnabled = false
                        }
                        else {
                            configureTextLableWithColor(UIColor.blueColor(), textAllignment: .Center)
                            self.userInteractionEnabled = true
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func configureTextLableWithColor(color: UIColor, textAllignment: NSTextAlignment) {
        self.titleLabel.textColor = color
        self.titleLabel.textAlignment = textAllignment
    }
    
    
    
    func configurePhotoState() {
    
        self.defineContentViewConstarints(140)
        self.titleLabel.alpha = 0
        self.photoImageView?.alpha = 1
        self.photoImageView?.image = cellData?.userData as? UIImage
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentViewHeightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant:50)
        self.contentView.addConstraint(self.contentViewHeightConstraint)
    }
    
    func defineContentViewConstarints(value: CGFloat) {
        
        self.contentViewHeightConstraint.constant = value
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.titleLabel.alpha = 1
        self.photoImageView?.alpha = 0
        defineContentViewConstarints(50)
        configureTextLableWithColor(UIColor.blackColor(), textAllignment: NSTextAlignment.Right)
        self.userInteractionEnabled = true
    }
    
   
}
