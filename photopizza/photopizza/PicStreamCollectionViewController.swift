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

private let reuseIdentifier = "BackendImage"


class PicStreamCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    
    var imgIDs: [String]?
    var imgs : [String : UIImage]?
    override func viewDidLoad() {
        super.viewDidLoad()
        dbListen()
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
       
    }
    
    func dbListen() {
        let postRef = FIRDatabase.database().reference().child("images")
        let addHandle = postRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            print("live added")
            print(snapshot.value!)
        })
        let removeHandle = postRef.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
            print("live remove")
            print(snapshot.value!)
            
            // ...
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
    func cleanString(base64str: String) -> String {
        
        //makes the key string of length 64
        //let endindex = base64str.startIndex.advancedBy(20)
        var subString = base64str.substringWithRange(Range<String.Index>(start: base64str.startIndex.advancedBy(1000), end: base64str.startIndex.advancedBy(1020)))
        
        //cleans string of /
        subString = subString.stringByReplacingOccurrencesOfString("/", withString: "7")
        
        //cleans string of .
        subString = subString.stringByReplacingOccurrencesOfString(".", withString: "8")
        
        //cleans string of #
        subString = subString.stringByReplacingOccurrencesOfString("#", withString: "9")
        
        //cleans string of $
        subString = subString.stringByReplacingOccurrencesOfString("$", withString: "1")
        
        //cleans string of [
        subString = subString.stringByReplacingOccurrencesOfString("[", withString: "2")
        
        //cleans string of ]
        subString = subString.stringByReplacingOccurrencesOfString("]", withString: "3")
        
        return subString
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

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return imgIDs?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
    
        // Configure the cell
    
        //cell.backgroundColor = UIColor.blackColor()
        //cell.designatedPic = UIImageView()
        cell.designatedPic.image = UIImage(named: "noAvatar")
        return cell
    }
    

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
