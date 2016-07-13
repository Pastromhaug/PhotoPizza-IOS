//
//  PicStreamCollectionViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/12/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftyJSON
import MWPhotoBrowser

private let reuseIdentifier = "BackendImage"


class PicStreamCollectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate {

    //MARK: Properties
    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    //@IBOutlet var picCollectionView: UICollectionView!
    
    var imgIDs: [String] = [String]()
    var imgs : [String : UIImage] = [String : UIImage]()
    var imgList : [UIImage] = [UIImage]()
    var photos = [MWPhoto]()
    var browser:MWPhotoBrowser
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        browser = MWPhotoBrowser(delegate: self)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.translucent = false
        initImageRefs()
        dbListen()
        photos += [MWPhoto(image: UIImage(named: "noAvatar"))]
        
        showFullScreenImage()
        //print(self.imgs.count)
        
        //self.loadView()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        
    }
    func showFullScreenImage() {
        imgList = Array(imgs.values)
        for img in imgList {
            self.photos += [MWPhoto(image: img)]
        }
        
        browser = MWPhotoBrowser(delegate: self)

        
        browser.displayActionButton = true
        browser.displayNavArrows = false
        browser.displaySelectionButtons = true
        browser.zoomPhotosToFill = true
        browser.alwaysShowControls = true
        browser.enableGrid = true
        browser.startOnGrid = true
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
    

    
//    islandRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
//    if (error != nil) {
//    // Uh-oh, an error occurred!
//    } else {
//    // Data for "images/island.jpg" is returned
//    // ... let islandImage: UIImage! = UIImage(data: data!)
//    }
//    }
    
    
    func initImageRefs() {
        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
        ref.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
            let json = JSON(snapshot.value!)["images"]
            for (key,subJson):(String, JSON) in json {
                let newval = subJson.string!
                self.imgIDs.append(newval)
                let photoRef = storageRef.child("images/" + newval)
                photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        // ... let islandImage: UIImage! = UIImage(data: data!)
                        self.imgs[newval] = UIImage(data: data!)
                        print("IMAGE COUNT: " + String(self.imgs.count))
                        //self.loadView()
                        //TODO: self.picCollectionView.reloadData()
                        self.browser.reloadData()
                    }
                }
                
                print(newval)
            }
            print("imgIDs")
            print(self.imgIDs)
            print("MASTER IMAGE COUNT: " + String(self.imgs.count))
        })
        
    }
    
    func dbListen() {
        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
        let postRef = FIRDatabase.database().reference().child("images")
        
        let addHandle = postRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            print("live added")
            print(snapshot.value!)
            let newval: String = snapshot.value as! String
            for ref in self.imgIDs {
                if ref == newval{
                    print(self.imgIDs)
                    return
                }
            }
            self.imgIDs.append(newval)
            let photoRef = storageRef.child("images/" + newval)
            photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    // ... let islandImage: UIImage! = UIImage(data: data!)
                    self.imgs[newval] = UIImage(data: data!)
                    //TODO: self.picCollectionView.reloadData()
                    self.browser.reloadData()
                }
            }
            //self.loadView()
            print(self.imgIDs)
           
        })
        let removeHandle = postRef.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
            print("live remove")
            print(snapshot.value!)
            let newval: String = snapshot.value as! String
            var len = self.imgIDs.count
            for i in 0..<len {
                let curr = self.imgIDs[i]
                if (curr == newval) {
                    self.imgIDs.removeAtIndex(i)
                    self.imgs.removeValueForKey(newval)
                    print(self.imgIDs)
                    //self.loadView()
                    //TODO: self.picCollectionView.reloadData()
                    return
                }
            }
            print(self.imgIDs)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func uploadPicture(sender: UIBarButtonItem) {
        print("hi")
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
        
        //select image from photo library
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //convert photo to string and clean it
        let uploadData: NSData = UIImageJPEGRepresentation(selectedImage, 0.9)!
        let fileString: String = uploadData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let subString = md5(string: fileString)
        
        
        print(subString)
        
        //uploads img to storage
        let imgRef = storageRef.child("images/" + subString + ".jpg")
        imgRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            if (error != nil) {
                print("Error in putData")
            }
            else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                print("putData succeeded")
                
                //uploads to real time database
                var dict = [String: String]()
                dict.updateValue(subString + ".jpg", forKey: subString)
                print(dict)
                self.ref.child("images").updateChildValues(dict)

            }
        })
        
    
        
        // Set photoImageView to display the selected image.
        //photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: UICollectionViewDataSource

//    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//
//    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of items
//        
//        imgList = Array(imgs.values)
//        //print("COUNT: " + String(imgIDs))
//        return imgList.count
//        //return 4
//    }
//
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
//    
//        // Configure the cell
//    
//        //cell.backgroundColor = UIColor.blackColor()
//        
//        imgList = Array(imgs.values)
//        cell.designatedPic.image = imgList[indexPath.row]
//        //cell.designatedPic.image = UIImage(named: "noAvatar")
//        return cell
//    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
