//
//  FCPublisherRootVCCollectionViewHeaderCollectionReusableView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 2/18/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class FCPublisherRootVCCollectionViewHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = UISearchBarStyle.Prominent
        searchBar.scopeButtonTitles = ["On Air" , "Off Air" , "Ends"]
        searchBar.showsScopeBar = true
        searchBar.selectedScopeButtonIndex = 0
        searchBar.sizeToFit()
        self.sizeToFit()
    }

    func setUp() {
        
        let white = UIColor.whiteColor()
        
        searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(white, view: self), forState: .Normal)
        
        
        let color = UIColor(red: 245, green: 221, blue: 249, alpha: 0.5)
                searchBar.setScopeBarButtonBackgroundImage(UIImage.imageWithColor(color, view: self), forState: .Selected)
        
        searchBar.scopeBarBackgroundImage = UIImage.imageWithColor(white, view: self)
    }
        
}
