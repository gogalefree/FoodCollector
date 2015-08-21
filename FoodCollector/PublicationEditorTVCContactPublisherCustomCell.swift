//
//  PublicationEditorTVCContactPublisherCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 08/08/15.
//  Copyright (c) 2015 Boris Tsigelman. All rights reserved.
//

import UIKit

class PublicationEditorTVCContactPublisherCustomCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var contactPubliserSwitch: UISwitch!
    
    
        
    @IBAction func contactPubliserSwitchAction(sender: UISwitch) {
        var typeOfCollecting = 1
        let contactDetails = (cellData!.userData as! NSDictionary).objectForKey(kPublicationContactInfoKey)! as! String
        cellData!.containsUserData = true
        
        
        if (sender.on == true) {
            typeOfCollecting = 2
            if (contactDetails.isEmpty) {
                cellData!.containsUserData = false
            }
        }
        
        println("------>>> contactPubliserSwitchAction: \(typeOfCollecting), No.: \(contactDetails)")
        
        let typeOfCollectingDict: [String : AnyObject] = [kPublicationTypeOfCollectingKey : typeOfCollecting , kPublicationContactInfoKey : contactDetails]
        cellData!.userData = typeOfCollectingDict
        
        
        if let delegate = self.delegate {
            delegate.updateData(cellData!, section: section!)
        }
    }
    
    
    var cellData: PublicationEditorTVCCellData? {
        
        didSet {
            
            if let cellData = self.cellData {
                
                self.cellLabel.text = cellData.cellTitle
            }
        }
    }
    
    var section: Int?
    
    var switchIsOn: Bool? {
        didSet {
            contactPubliserSwitch.setOn(switchIsOn!, animated: true)
        }
    }
    
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
