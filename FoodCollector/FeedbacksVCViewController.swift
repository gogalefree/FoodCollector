//
//  FeedbacksVCViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 06/12/2015.
//  Copyright © 2015 Foodonet. All rights reserved.
//

import UIKit

class FeedbacksVCViewController: UIViewController , UITextViewDelegate{

    @IBOutlet weak var titleLabel               : UILabel!
    @IBOutlet weak var reportTextView           : UITextView!
    @IBOutlet weak var sendButton               : UIButton!
    @IBOutlet weak var backroundView            : UIView!
    @IBOutlet weak var popupBackroundView       : UIView!

    
    let placeHolderMessage = String.localizedStringWithFormat("שתפו אותנו במחשבות, הצעות ובכל דבר אחר", "")
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
    
        reportTextView.delegate = self
        reportTextView.text = placeHolderMessage
        reportTextView.textColor = UIColor.lightGrayColor()
        popupBackroundView.layer.cornerRadius = 5
    }
    
    @IBAction func sendButtonAction(sender: UIButton!) {
        
        let report = self.reportTextView.text
        if report != "" && report != placeHolderMessage {
        
            FCModel.sharedInstance.foodCollectorWebServer.sendFeedback(report)
            self.dissmiss()
        }
    }
    
    @IBAction func dissmiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
       
        if textView.text == placeHolderMessage {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
            textView.textAlignment = NSTextAlignment.Natural
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.reportTextView.resignFirstResponder()
    }
 }
