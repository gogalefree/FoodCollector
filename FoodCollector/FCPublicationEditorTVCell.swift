//
//  FCPublicationEditorTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 1/13/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublicationEditorTVCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    var contentViewHeightConstraint: NSLayoutConstraint!
    var photoImageView: UIImageView?
    var indexPath: NSIndexPath?
    var cellData: FCPublicationEditorTVCCellData? {
        didSet {
            if let cellData = self.cellData {
                
                self.titleLabel.text = cellData.cellTitle
                
                if let indexpath = self.indexPath {
                    
                    
                    switch indexpath.section {
                        
                    case 6:
                        //photo cell
                        if cellData.containsUserData {
                            
                            if cellData.userData is UIImage {
                                configurePhotoState()
                            }
                        }
                    case 7:
                        //take off air cell
                        configureTextLableWithColor(UIColor.lightGrayColor(), textAllignment: .Center)
                        self.userInteractionEnabled = false
                        
                    case 8:
                        //publish cell
                        configureTextLableWithColor(UIColor.lightGrayColor(), textAllignment: .Center)
                        self.userInteractionEnabled = false
                        
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
        self.photoImageView = UIImageView(frame: CGRectMake(0, 0, 120, 120))
        self.photoImageView?.image = cellData?.userData as? UIImage
        self.defineContentViewConstarints(140)
        self.titleLabel.alpha = 0
        self.contentView.addSubview(self.photoImageView!)
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
        if let photoImageView = self.photoImageView {
            photoImageView.removeFromSuperview()
            self.photoImageView = nil
        }
        
        defineContentViewConstarints(50)
        configureTextLableWithColor(UIColor.blackColor(), textAllignment: NSTextAlignment.Right)
        self.userInteractionEnabled = true

    }
    
   
}
