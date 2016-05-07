//
//  GroupDetailsMemberTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 25/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

protocol GroupDetilsTVCellDelegate: NSObjectProtocol {

    func didRequestCellDelete()
}

class GroupDetailsMemberTVCell: UITableViewCell {
    
    @IBOutlet weak var memberIcon: UIImageView!
    @IBOutlet weak var memberNameLable: UILabel!
    @IBOutlet weak var deleteCellButton: UIButton!
    @IBOutlet weak var isAdminLabel: UILabel!
    var isGroupAdmin = false
    let icons = [UIImage(named: "Notusericon") ,UIImage(named: "Usericon") ]
    weak var delegate: GroupDetilsTVCellDelegate?
    
    var groupMember: GroupMember! {
        didSet{
            guard let groupMember = groupMember else {return}
            setup(groupMember)
        }
    }

    func setup(groupMemeber: GroupMember){
    
        let isUser = groupMemeber.isFoodonetUser!.boolValue == true || groupMemeber.userId! != 0 ? true : false
        memberIcon.image = icons[isUser.boolValue.hashValue]
        memberNameLable.text = groupMemeber.name
        isAdminLabel.text = groupMemeber.isAdmin!.boolValue ? kAdminString : ""
        isAdminLabel.textColor = kGroupsRootvcTVCellIsAdminColor
        self.deleteCellButton.alpha = CGFloat(isGroupAdmin.hashValue)
        
    }
    
    @IBAction func deleteCellTapped(sender: AnyObject) {
        self.delegate?.didRequestCellDelete()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
