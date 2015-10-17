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
    
    var cellState = CellState.Display
    
    var cellData: PublicationEditorVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                switch cellState {
                case .Display:
                    cellLabel.alpha = 1
                    self.cellLabel.text = cellData.cellTitle
                case .Edit:
                    cellLabel.alpha = 1
                    
                    let txtField = UITextField(frame: CGRect(x: 8, y: 0, width: self.frame.width-10, height: self.frame.height-1))
                    txtField.clearButtonMode = UITextFieldViewMode.WhileEditing
                    txtField.text = cellData.userData as? String
                    self.addSubview(txtField)
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
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
