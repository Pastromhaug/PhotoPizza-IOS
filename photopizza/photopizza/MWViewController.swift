//
//  MWViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/13/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import MWPhotoBrowser

class MWViewController: UINavigationController, MWPhotoBrowserDelegate {

    var photos = [MWPhoto]()
    override func viewDidLoad() {
        super.viewDidLoad()
        showFullScreenImage()
    }
    
    func showFullScreenImage() {
        let photo:MWPhoto = MWPhoto(image: UIImage(named: "noAvatar"))
        
        self.photos = [photo]
        
        let browser:MWPhotoBrowser = MWPhotoBrowser(delegate: self)
        
        browser.displayActionButton = true
        browser.displayNavArrows = false
        browser.displaySelectionButtons = false
        browser.zoomPhotosToFill = true
        browser.alwaysShowControls = false
        browser.enableGrid = false
        browser.startOnGrid = false
        browser.enableSwipeToDismiss = true
        
        browser.setCurrentPhotoIndex(0)
        
        self.navigationController?.pushViewController(browser, animated: true)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(self.photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if Int(index) < self.photos.count {
            return photos[Int(index)] as! MWPhoto
        }
        return nil
    }
    
    func photoBrowserDidFinishModalPresentation(photoBrowser:MWPhotoBrowser) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
