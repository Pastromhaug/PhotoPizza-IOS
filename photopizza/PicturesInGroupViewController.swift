//
//  PicturesInGroupViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/12/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class PicturesInGroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Navigation
    let storage = FIRStorage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let uploadData: NSData = UIImagePNGRepresentation(selectedImage)!
        
        let fileString: String = uploadData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let endindex = fileString.startIndex.advancedBy(20)
        let substring = fileString.substringToIndex(endindex)
        print(substring)
        
        let imgRef = storageRef.child("images/" + substring)

        imgRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            if (error != nil) {
                print("Error in putData")
            }
            else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                print("putData succeeded")
//                let downloadURL = metadata!.downloadURL
//                print("downloadURL: " + downloadURL)
            }
        })
        
//        storageRef.putData(uploadData!, metadata: nil)
        
        
        
        // The info dictionary contains multiple representations of the image, and this uses the original.
        //let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        //photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
