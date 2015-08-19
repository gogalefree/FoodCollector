//
//  PublicationEditorTVCPhoneNumEditorCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 15/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCPhoneNumEditorCustomCell: UITableViewCell {
    
    
    @IBOutlet weak var cellPhoneField: UITextField!
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if let cellPhoneField = self.cellData {
                let typeOfPublicationRawValue = cellData!.userData.objectForKey(kPublicationTypeOfCollectingKey) as! Int
                let cellTitle = cellData!.userData.objectForKey(kPublicationContactInfoKey) as! String
                if (typeOfPublicationRawValue == 2){
                    if (cellTitle != "") {
                        self.cellPhoneField.text = cellTitle
                    }
                }
            }
        }
    }
    
    var section: Int?
    
    var delegate: CellInfoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
