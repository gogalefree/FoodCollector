//
//  ActivityLogTVCell.swift
//  FoodCollector
//
//  Created by Guy Freedman on 20/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class ActivityLogTVCell: UITableViewCell {
    
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    /*NoPhotoPlaceholder*/
    let defaultImage = UIImage(named: "Big_Logo")
    let tagIconsNames = ["EndedTag" , "Group_tag_1", "JoinedTag", "NewEventTag", "ReportTag"]
    
    var log: ActivityLog! {
        didSet {
            guard let newLog = log else {return}
            setup(newLog)
        }
    }

    func setup(newlog: ActivityLog) {
    
        if newlog.isNew?.boolValue == true {setGrayBackrounds()}
        titleLabel.text = newlog.title
        subtitleLabel.text = newlog.subtitle
        timeLabel.text = newlog.timeStringFromCreation
        setupMainImage(newlog)
        setupIconImageAndTextColor(newlog)
    }
    
    func setupMainImage(newlog: ActivityLog) {
       
        mainImageView.layer.cornerRadius = CGRectGetWidth(mainImageView.bounds) / 2
        guard let imageData = newlog.logImage else {
            self.mainImageView.image = defaultImage
            self.mainImageView.contentMode = .ScaleAspectFit
            return
        }
        
        self.mainImageView.contentMode = .ScaleToFill
        let image = UIImage(data: imageData)
        self.mainImageView.image = image
    }
    
    func setupIconImageAndTextColor(newlog: ActivityLog){
        
        iconImageView.layer.cornerRadius = CGRectGetWidth(iconImageView.bounds) / 2
        iconImageView.layer.borderWidth = 2
        iconImageView.layer.borderColor = UIColor.lightTextColor().CGColor
        var icon: UIImage?
        
        let logType = ActivityLog.LogType(rawValue: (newlog.type?.integerValue) ?? 1)
        
        guard let type = logType else {
        
            self.iconImageView.image = UIImage(named: tagIconsNames[3])
            return
        }
        
        switch type {
            
        case .NewPublication:
            icon = UIImage(named: tagIconsNames[3])
            titleLabel.textColor = kNavBarBlueColor
            
        case .DeletePublication:
            icon = UIImage(named: tagIconsNames[0])
            titleLabel.textColor = UIColor.redColor()

        case .Report:
            icon = UIImage(named: tagIconsNames[4])
            titleLabel.textColor = UIColor.purpleColor()
            
        case .Registration:
            icon = UIImage(named: tagIconsNames[2])
            titleLabel.textColor = UIColor.greenColor()
            
        case .NewGroup:
            icon = UIImage(named: tagIconsNames[1])
            titleLabel.textColor = UIColor.orangeColor()
            //iconImageView.backgroundColor = UIColor.orangeColor()
        }
        
        self.iconImageView.image = icon
    }
    
    func setGrayBackrounds() {
        titleLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
        subtitleLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
        contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        timeLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.log.isNew = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.backgroundColor = UIColor.whiteColor()
        subtitleLabel.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor.whiteColor()
        timeLabel.backgroundColor = UIColor.whiteColor()
        self.mainImageView.contentMode = .ScaleToFill
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
