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
import DKImagePickerController
import Agrume
import Photos


private let reuseIdentifier = "BackendImage"


class PicStreamCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {

    //MARK: Properties
    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    @IBOutlet var picCollectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var imgIDs: [String] = [String]()
    var imgs : [String : UIImage] = [String : UIImage]()
    var imgList : [UIImage] = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barTintColor = UIColor(red:0.38, green:0.28, blue:0.62, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)]
        navigationController!.navigationBar.tintColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)
        self.collectionView?.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)


        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        //self.navigationController?.navigationBar.translucent = false
        initImageRefs()
        dbListen()
        
//
        
        
        //print(self.imgs.count)
        
        //self.loadView()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenWidth/5, screenWidth/5 );
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0;
    }
    
    
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
                        self.picCollectionView.reloadData()
                        
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
                    self.picCollectionView.reloadData()
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
                    self.picCollectionView.reloadData()
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
        let pickerController = DKImagePickerController()
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            let storageRef = self.storage.referenceForURL("gs://photo-pizza.appspot.com")
            print("didSelectAssets")
            print(assets)
            for object in assets {
                object.fetchOriginalImageWithCompleteBlock { (image, info) -> Void in
                    //convert photo to string and clean it
                    let uploadData: NSData = UIImageJPEGRepresentation(image!, 0.05)!
                    let fileString: String = uploadData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                    let subString = self.md5(string: fileString)
                    
                    
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
                    
                }
            }
            
            

        }
        pickerController.showsCancelButton = true
        var dkassets = [DKAsset]()
        print("")
        print(self.images)
        for image in self.images {
            print("image")
            print(image)
            dkassets.append(DKAsset(image: image))
        }
        pickerController.defaultSelectedAssets = dkassets
        self.presentViewController(pickerController, animated: true) {}    }

    
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

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        imgList = Array(imgs.values)
        //print("COUNT: " + String(imgIDs))
        return imgList.count
        //return 4
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
    
        // Configure the cell
    
        //cell.backgroundColor = UIColor.blackColor()
        
        imgList = Array(imgs.values)
        if (cell.designatedPic == nil) {
            
        }
        cell.designatedPic.image = imgList[indexPath.row]
        //cell.designatedPic.image = UIImage(named: "noAvatar")
        cell.layer.borderWidth = 0
        cell.frame.size.width = screenWidth / 5
        cell.frame.size.height = screenWidth / 5
        
    
        return cell
    }
    

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let agrume = Agrume(images: imgList, startIndex: indexPath.row, backgroundBlurStyle: .Light)
        agrume.didScroll = {
            [unowned self] index in
            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0),
                                                         atScrollPosition: [],
                                                         animated: false)
        }
        agrume.showFrom(self)
    }
    
    var images: [UIImage] = [] // <-- Array to hold the fetched images
    var totalImageCountNeeded:Int! // <-- The number of images to fetch
    
    func fetchPhotos () {
        images = [UIImage]()
        totalImageCountNeeded = 3
        self.fetchPhotoAtIndexFromEnd(0)
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndexFromEnd(index:Int) {
        
        let imgManager = PHImageManager.defaultManager()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            
            // If the fetch result isn't empty,
            // proceed with the image request
            print("fetchResult.count")
            print(fetchResult.count)
            if fetchResult.count > 0 {
                // Perform the image request
                imgManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    // Add the returned image to your array
                    self.images.append(image!)
                    
                    // If you haven't already reached the first
                    // index of the fetch result and if you haven't
                    // already stored all of the images you need,
                    // perform the fetch request again with an
                    // incremented index
                    if index + 1 < fetchResult.count && self.images.count < self.totalImageCountNeeded {
                        self.fetchPhotoAtIndexFromEnd(index + 1)
                    } else {
                        // Else you have completed creating your array
                        print("Completed array: \(self.images)")
                    }
                })
            }
        }
    }


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
