//
//  ContactCollectorPickerCollectorDetailsCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 31/10/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class ContactCollectorPickerCollectorDetailsCell: UITableViewCell {
    
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var mainLabel        : UILabel!
    @IBOutlet weak var seperatorView    : UIView!
    
    let checkBoxImages = [UIImage(named: "Checkbox")! , UIImage(named: "Checkbox_Checked")!]
    var chosen = false
    var registration: FCRegistrationForPublication? 

    var indexPath: NSIndexPath? {
    
        didSet {
            setup()
        }
    }

    func setup() {
    
        self.checkBoxImageView.image = checkBoxImages[chosen.hashValue]
        var title = ""
        
        switch indexPath!.section {
            
        case 0:
            title = String.localizedStringWithFormat("Select all", "Chose all collectors")
            self.mainLabel.font = UIFont.boldSystemFontOfSize(17)
            self.seperatorView.backgroundColor = UIColor.blackColor()
            
        case 1:
            title = registration?.collectorName ?? String.localizedStringWithFormat("No name", "Display 'NoName' when there's no collectore name")
            self.seperatorView.backgroundColor = UIColor.lightGrayColor()
            self.mainLabel.font = UIFont.systemFontOfSize(17)
            
        default:
            title = ""
            self.seperatorView.backgroundColor = UIColor.clearColor()
        }
        
        self.mainLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            chosen = !chosen
            reloadImage()
        }
    }
    
    func reloadImage() {
        
        self.checkBoxImageView.image = self.checkBoxImages[self.chosen.hashValue]
    }
}
