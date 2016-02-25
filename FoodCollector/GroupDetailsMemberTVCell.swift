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
    
        memberIcon.image = icons[(groupMember.isFoodonetUser?.boolValue.hashValue)!]
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
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
