//
//  FCPublicationDetailsView.swift
//  FoodCollector
//
//  Created by Guy Freedman on 10 Nov 2014.
//  Copyright (c) 2014 UPP Project . All rights reserved.
//

import UIKit
import Foundation



protocol FCPublicationDetailsViewDelegate {
    
    /// dismisses the details view
    
    func publicationDetailsViewDidCancel()
    
    
    /// user wants to navigate to the publication.
    /// should result with an action sheet on which the user selects to navigate
    ///  with Waze or Maps
    
    func didRequestNavigationForPublication(publication:FCPublication)
    
    
    /// the user intends to go and pick up from this publication.
    
    func didOrderCollectionForPublication(publication: FCPublication)
    
}



/// presents the details of a Publication


class FCPublicationDetailsView : UIView {
    
    var delegate:FCPublicationDetailsViewDelegate!
    
    
    
}

