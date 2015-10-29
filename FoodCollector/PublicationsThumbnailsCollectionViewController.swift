//
//  PublicationsThumbnailsCollectionViewController.swift
//  FoodCollector
//
//  Created by Guy Freedman on 26/10/2015.
//

import UIKit

class PublicationsThumbnailsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var publications = FCModel.sharedInstance.publications
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.backgroundColor = kNavBarBlueColor.colorWithAlphaComponent(0.3)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRecieveNewData", name: kRecievedNewDataNotification, object: nil)
    }
    
    //MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.publications.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(thumbnailCollectionViewCellID, forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        cell.publication = publications[indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
     
        
        let mapVC = self.parentViewController as? FCCollectorRootVC
        mapVC?.didSelectThumbnailForPublication(self.publications[indexPath.item])
    }
    //MARK: New data notification
    
    func didRecieveNewData() {
    
      //  self.collectionView.performBatchUpdates({ () -> Void in
            self.publications = FCModel.sharedInstance.publications
            self.collectionView.reloadData()
            
        //    }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
