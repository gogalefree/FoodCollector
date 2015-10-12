//
//  PublicationPhotoPresentorVC.swift
//  FoodCollector
//
//  Created by Guy Freedman on 3/11/15.
//  Copyright (c) 2015 Guy Freeman. All rights reserved.
//

import UIKit

class PublicationPhotoPresentorVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewButtomConstraint: NSLayoutConstraint!

    let initialScrollViewButtomConstartintConstant: CGFloat = 176.0 //236.0
    let initialScrollViewTopConstartintConstant: CGFloat = 60.0 //0.0

    var scrollViewZoomed = false
    var publication: FCPublication!
    var myImageView: UIImageView!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.modalPresentationStyle = .Custom
        self.scrollView.delegate = self
        self.scrollView.contentSize = self.publication.photoData.photo!.size;
        self.upDateConstraints(self.view.frame.size)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        addImageView()
        adjustScrollView()
        addGestureToScrollView()
    }
    
    func addImageView() {

        if self.myImageView == nil {
        
            let image = publication.photoData.photo!
            myImageView = UIImageView(image: image)
            myImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
            scrollView.addSubview(myImageView)
        }
    }
    
    func adjustScrollView() {
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in

            let boundsSize = self.scrollView.bounds.size
            var contentsFrame = self.myImageView.frame
            
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            }
            else {
                contentsFrame.origin.x = 0.0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            }
            else {
                contentsFrame.origin.y = 0.0
            }
            
            self.myImageView.frame = contentsFrame
        }, completion: nil)
    }
    
    func addGestureToScrollView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "scrollViewTapped:")
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        self.scrollView.addGestureRecognizer(tapGesture)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewTapped(recognizer: UITapGestureRecognizer) {

        scrollViewZoomed = !scrollViewZoomed
        self.upDateConstraints(self.view.frame.size)
        
        if scrollViewZoomed {
            UIView.animateWithDuration(0.3, animations: { () -> Void in

                let pointInView = recognizer.locationInView(self.myImageView)
                var newZoomScale = self.scrollView.zoomScale * 1.5
                newZoomScale = max(newZoomScale, self.scrollView.maximumZoomScale)
                
                let scrollViewSize = self.scrollView.bounds.size
                let w = scrollViewSize.width / newZoomScale
                let h = scrollViewSize.height / newZoomScale
                let x = pointInView.x - (w / 2.0)
                let y = pointInView.y - (h / 2.0)
                
                let rectToZoomTo = CGRectMake(x, y, w, h);
                self.scrollView.zoomToRect(rectToZoomTo, animated: true)
                self.scrollView.scrollEnabled = true
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
      
                self.adjustScrollView()
                self.centerScrollViewContents()
                self.scrollView.scrollEnabled = false
            })
        }
    }
    
    func upDateConstraints(size: CGSize) {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            switch self.scrollViewZoomed {
                
            case true:
                
                self.scrollViewTopConstraint.constant = 0
                self.scrollViewButtomConstraint.constant = 0
                
            case false:
                if size.height < size.width {
                    //portarit
                    
                    self.scrollViewTopConstraint.constant = 0
                    self.scrollViewButtomConstraint.constant = 0
                }
                else {
                    //landscape
                    self.scrollViewTopConstraint.constant = self.initialScrollViewTopConstartintConstant
                    self.scrollViewButtomConstraint.constant = self.initialScrollViewButtomConstartintConstant
                }
            }
            
            self.view.layoutIfNeeded()
        })
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.myImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        if scrollView.zoomScale == self.scrollView.minimumZoomScale && self.scrollViewZoomed{
            self.scrollViewZoomed = false
            self.upDateConstraints(self.view.frame.size)
            scrollView.scrollEnabled = false
            self.centerScrollViewContents()
        }
    }
    
    @IBAction func dissmiss() {
        
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            
            self.scrollViewTopConstraint.constant -= 30
            self.scrollViewButtomConstraint.constant += 30
            self.view.layoutIfNeeded()
             self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            return
            
            }) { (finished) -> Void in}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.myImageView = nil
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ (context) -> Void in
     
            self.upDateConstraints(size) },
            
            completion: { (context) -> Void in
            
                if !self.scrollViewZoomed{ self.centerScrollViewContents()}
            })
    }
 }
