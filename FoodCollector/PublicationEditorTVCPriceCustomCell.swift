//
//  PublicationEditorTVCPriceCustomCell.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 10.6.2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class PublicationEditorTVCPriceCustomCell: UITableViewCell {
    
    let kNumberPadDoneTitle = String.localizedStringWithFormat("Done", "Done lable for button")
    let kNumberPadDismissTitle = String.localizedStringWithFormat("Cancel", "Cancel lable for button")
    
    @IBOutlet weak var amountInput: UITextField!
    @IBOutlet weak var currencySymbol: UILabel!
    
    var cellData: PublicationEditorTVCCellData? {
        didSet {
            if cellData != nil {
                if cellData?.cellTitle != "" {
                    //print("cellData!.cellTitle: \(cellData!.cellTitle)")
                    self.amountInput.text = cellData!.cellTitle
                }
            }
        }
    }
    
    var section: Int?
    
    weak var delegate: CellInfoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //amountInput.delegate = self
        createNumberPadAccessoryViewToolbar()
    }
    
    private func createNumberPadAccessoryViewToolbar(){
        let buutonWidth = CGFloat(50)
        let numberPadAccessoryViewToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        
        let cancelButton = UIBarButtonItem(title: kNumberPadDismissTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissNumberPad))
        cancelButton.width = buutonWidth
        
        let flexibleSpaceButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: kNumberPadDoneTitle, style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneNumberPad))
        doneButton.width = buutonWidth
        
        numberPadAccessoryViewToolbar.items = [cancelButton, flexibleSpaceButtonItem, doneButton]
        numberPadAccessoryViewToolbar.sizeToFit()
        
        amountInput?.inputAccessoryView = numberPadAccessoryViewToolbar
        
    }
    
    func dismissNumberPad() {
        amountInput.text = ""
        amountInput?.resignFirstResponder()
    }
    
    func doneNumberPad() {
        print("doneNumberPad()")
        if(amountInput.text!.isEmpty) {
            dismissNumberPad()
        }
        else {
            print("amountInput.text!: \(amountInput.text!)")
            cellData!.cellTitle = amountInput.text!
            cellData!.userData = Double(amountInput.text!)!
            print("cellData!.cellTitle = \(cellData!.cellTitle)")
            print("cellData!.userData = \(cellData!.userData)")
            if let delegate = self.delegate {
                delegate.updateData(cellData!, section: section!)
            }
        }
    }
    
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
