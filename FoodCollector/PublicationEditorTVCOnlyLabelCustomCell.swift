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
    
    //var cellState = CellState.Display
    
    let cellLabelColor = UIColor(red: 0.74, green: 0.74, blue: 0.76, alpha: 1.00)
    
    var cellData: PublicationEditorTVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                cellLabel.alpha = 1
                self.cellLabel.text = cellData.cellTitle
                if cellData.containsUserData == true {
                    self.cellLabel.textColor = UIColor.blackColor()
                }
                
                /*
                switch cellState {
                case .Display:
                    cellLabel.alpha = 1
                    self.cellLabel.text = cellData.cellTitle
                    if cellData.containsUserData != true {
                        self.cellLabel.textColor = UIColor(red: 0.74, green: 0.74, blue: 0.76, alpha: 1.00)
                    }
                case .Edit:
                    cellLabel.alpha = 1
                    
                    let txtField = UITextField(frame: CGRect(x: 8, y: 0, width: self.frame.width-10, height: self.frame.height-1))
                    txtField.clearButtonMode = UITextFieldViewMode.WhileEditing
                    txtField.text = cellData.userData as? String
                    self.addSubview(txtField)
                } */
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cellLabel.textColor = cellLabelColor
        
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
