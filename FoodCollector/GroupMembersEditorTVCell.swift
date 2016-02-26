//
//  GroupMembersEditorTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/02/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class GroupMembersEditorTVCell: UITableViewCell {

    
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: GroupDetilsTVCellDelegate?
    
    var groupMemberData: GroupMemberData! {
        didSet {
            guard let data = groupMemberData else {return}
            setup(data)
        }
    }
    
    func setup(memberData: GroupMemberData) {
    
        memberNameLabel.text = memberData.name
    }
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
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
