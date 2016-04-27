//
//  PublicationDetailsVC+PhotoPresentor.swift
//  FoodCollector
//
//  Created by Guy Freedman on 24/04/2016.
//  Copyright © 2016 Foodonet. All rights reserved.
//

import Foundation

extension PublicationDetailsVC: UIViewControllerTransitioningDelegate{
    
    func presentPhotoPresentor() {
        
        //add if to check whether there's a photo or default
        if self.publication?.photoBinaryData == nil {return}

        self.photoPresentorNavController = self.storyboard?.instantiateViewControllerWithIdentifier("photoPresentorNavController") as! FCPhotoPresentorNavigationController

        self.photoPresentorNavController.transitioningDelegate = self
        self.photoPresentorNavController.modalPresentationStyle = .Custom

        let photoPresentorVC = self.photoPresentorNavController.viewControllers[0] as! PublicationPhotoPresentorVC
        photoPresentorVC.publication = self.publication

        self.navigationController?.presentViewController(
            self.photoPresentorNavController, animated: true, completion:nil)
    }



        //MARK: - Transition Delegate
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {

        var pcontrol: UIPresentationController!

        if presented is FCPhotoPresentorNavigationController {

            pcontrol = PublicationPhotoPresentorPresentationController(
            presentedViewController: self.photoPresentorNavController,
            presentingViewController: self.navigationController!)
        }

        else if presented is FCPublicationReportsNavigationController{

            pcontrol = FCPublicationReportsPresentationController( presentedViewController: self.publicationReportsNavController,
                presentingViewController: self.navigationController!)
        }

        return  pcontrol
    }

        func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
            //starting frame for transition
            if presented is FCPhotoPresentorNavigationController {
    
                let photoPresentorVCAnimator = PublicationPhotoPresentorAnimator()
    
                var originFrame = CGRectZero
                //TODO: set initial photo frame
                let imageCellIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                let imageCell = self.shareDetailsTableView.cellForRowAtIndexPath(imageCellIndexPath) as? PublicationDetailsImageTVCell
                if let cell = imageCell {
                    originFrame = self.view.convertRect(cell.shareDetailsImage.frame, fromView: cell)
                }
    
                photoPresentorVCAnimator.originFrame = originFrame
                return photoPresentorVCAnimator
            }
    
            else if presented is FCPublicationReportsNavigationController{
    
                let publicationReportsAnimator = FCPublicationReportsVCAnimator()
                var startingFrame = self.shareDetailsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        //        startingFrame.origin.y += kTableViewHeaderHeight
                startingFrame.size.width = startingFrame.size.width / 2
    
                publicationReportsAnimator.originFrame = startingFrame
                return publicationReportsAnimator
    
            }
    
            return nil
        }
    
        func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
            if dismissed is FCPhotoPresentorNavigationController {
                return PublicationPhotoPresentorDissmissAnimator()
            }
            else if dismissed == self.publicationReportsNavController {
    
                let animator = FCPublicationReportsDismissAnimator()
    
                let destinationFrame =
                self.shareDetailsTableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
                
                animator.destinationRect = destinationFrame
                
                return animator
            }
            
            return nil
        }

}