//
//  FCPublishStringFieldsEditorVC.swift
//  FoodCollector
//
//  Created by Boris Tsigelman on 20/12/14.
//  Copyright (c) 2014 Guy Freeman. All rights reserved.
//

import UIKit
import QuartzCore

let titleEditorTitle = String.localizedStringWithFormat("הוספת שם", "the editor title for enter a publication name")
let subTitleEditorTitle = String.localizedStringWithFormat("הוספת תיאור", "the editor title for enter a publication name")

class FCPublishStringFieldsEditorVC: UIViewController, UITextViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    var celldata = FCPublicationEditorTVCCellData()
    
    enum DisplayState: Int {
        case textField = 0
        case textView = 1
    }
    
    var state: DisplayState = .textField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.textView.delegate = self
        configureState()
        configureInitialText()
    }
    
    func configureInitialText() {
        var initialText = ""
        if self.celldata.containsUserData {
            initialText = self.celldata.cellTitle
        }
        
        switch self.state {
        case .textField:
            self.textField.text = initialText
        
        case .textView:
            self.textView.text = initialText
        }
    }
    
    func configureState() {
        self.textView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.textView.layer.borderWidth = 1
        self.textView.layer.cornerRadius = 2
        
            switch self.state {
                
            case DisplayState.textField:
                self.textField.alpha = 1
                self.textField.becomeFirstResponder()
                self.textView.alpha = 0
                self.title = titleEditorTitle
                
            case DisplayState.textView:
                self.textField.alpha = 0
                self.textView.alpha = 1
                self.textView.becomeFirstResponder()
                self.title = subTitleEditorTitle
            default:
                break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.dissmissKeyBoard()
        switch self.state {
        case .textField:
            if !self.textField.text.isEmpty {
                self.celldata.userData = self.textField.text
                self.celldata.cellTitle = self.textField.text
                self.celldata.containsUserData = true
            }
        
        case .textView:
            if !self.textView.text.isEmpty {
                self.celldata.userData = self.textView.text
                self.celldata.cellTitle = self.textView.text
                self.celldata.containsUserData = true
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.dissmissKeyBoard()
    }
    
    func dissmissKeyBoard() {
        self.textField.resignFirstResponder()
        self.textView.resignFirstResponder()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
   }
