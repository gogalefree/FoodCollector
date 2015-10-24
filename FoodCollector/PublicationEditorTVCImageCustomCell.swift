//
//  PublicationEditorTVCImageCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 08/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCImageCustomCell: UITableViewCell {
    
    //@IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var publicationImage: UIImageView!
    
    @IBOutlet weak var pictureButton: UIButton!
    
    var section: Int?
    
    var cameraButtonClicked: ((PublicationEditorTVCImageCustomCell) -> Void)?
    
    var cellData: PublicationEditorTVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                //self.cellLabel.text = cellData.cellTitle
                
                self.publicationImage.image = cellData.userData as? UIImage
                //self.publicationImage.layer.cornerRadius = self.publicationImage.frame.height/2
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //pictureButton.addTarget(self, action: "photoButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    //func photoButtonClicked(){
        //cameraButtonClicked!(self)
    //}
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.cellLabel.text = ""
    }
    
}

