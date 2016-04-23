//
//  ArrivedToSpotCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 23/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class ArrivedToSpotCell: UITableViewCell {

    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var reportMessageLabel: UILabel!
    
    let radioIcons = [UIImage(named: "AudianceSelectionUnchecked") , UIImage(named: "AudianceSelectionChecked") ]
    
    let titles = [NSLocalizedString("Has More To Pickup", comment: "report button title"), NSLocalizedString("I Took All", comment: "report button title"), NSLocalizedString("Fount Nothing There", comment: "report button title")]
    
    var indexPath: NSIndexPath! {
        
        didSet {
    
            guard let ip = indexPath else {return}
            reportMessageLabel.text = titles[ip.row]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        radioImageView.image = radioIcons[0]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let selection = selected.hashValue
        radioImageView.image = radioIcons[selection]
    }

}
