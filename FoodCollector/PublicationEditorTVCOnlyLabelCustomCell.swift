//
//  PublicationEditorTVCOnlyLabelCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 08/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCOnlyLabelCustomCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.addressName.text = self.addressListItem
        //println("self.addressName.text: \(self.addressName.text)")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellLabel.text = ""
    }
    
}
