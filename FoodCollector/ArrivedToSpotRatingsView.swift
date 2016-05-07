//
//  ArrivedToSpotRatingsView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 01/05/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import UIKit

class ArrivedToSpotRatingsView: UIView {

    @IBOutlet weak var oneStarButton: UIButton!
    @IBOutlet weak var twoStarButton: UIButton!
    @IBOutlet weak var threeStarButton: UIButton!
    @IBOutlet weak var fourStarButton: UIButton!
    @IBOutlet weak var fiveStarButton: UIButton!

    let whiteStar = UIImage(named: "Star")
    let yellowStar = UIImage(named: "Star-filled")
    
    private var buttons = [UIButton]()
    var ratings = 5
    
    @IBAction func starButtonClicked(sender: UIButton) {
        
        let button = sender
        let index = buttons.indexOf(button)
        if let btnIndex = index {
         
            let index = btnIndex.hashValue
            configureButtons(index)
        }
     
    }
    
    private func configureButtons(index: Int) {
        
        //highLight
        for i in 0...index {
            
            let button = buttons[i]
            button.setImage(yellowStar, forState: .Normal)
        }
        
        let count = self.buttons.count
        if count == index + 1 {return}
        
        for f in index + 1..<count  {
            
            let button = buttons[f]
            button.setImage(whiteStar, forState: .Normal)
        }
        
        ratings = index + 1
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        buttons = [oneStarButton, twoStarButton, threeStarButton, fourStarButton, fiveStarButton]
        for i in 0..<buttons.count {
            let button = buttons[i]
            button.setImage(yellowStar, forState: .Normal)
        }
    }
}
