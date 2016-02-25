//
//  GroupsRootvcTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 24/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

let kGroupsRootvcTVCellTextColor    = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
let kGroupsRootvcTVCellIsAdminColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
let kAdminString = NSLocalizedString("Admin", comment: "label title indicating that the user is the group admin")

class GroupsRootvcTVCell: UITableViewCell {

    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var isAdminLabel: UILabel!
    @IBOutlet weak var groupMembersCountLabel: UILabel!
    
    
    var group: Group! {
        didSet {
            guard let group = group else {return}
            setup(group)
        }
    }
    
    func setup(group: Group) {
    
        groupNameLabel.textColor = kGroupsRootvcTVCellTextColor
        isAdminLabel.textColor = kGroupsRootvcTVCellIsAdminColor
        
        groupNameLabel.text = group.name
        groupMembersCountLabel.text = group.members != nil ? String(group.members!.count) : "0"
        isAdminLabel.text = group.adminUserId == User.sharedInstance.userUniqueID ? kAdminString : ""
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
