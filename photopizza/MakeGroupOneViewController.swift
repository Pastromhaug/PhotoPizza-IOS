//
//  MakeGroupOneViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/10/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import DKImagePickerController
import Firebase

class MakeGroupOneViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    var group: Group?
    var avatarImageId: String = ""
    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        nextButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMealname()
        navigationItem.title = textField.text
    }

    func checkValidMealname() {
        let text = groupTextField.text ?? ""
        nextButton.enabled = !text.isEmpty
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        avatarImage.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func selectAvatarAction(sender: UITapGestureRecognizer) {
        let pickerController = DKImagePickerController()
        pickerController.showsCancelButton = true
        pickerController.sourceType = .Photo
        pickerController.singleSelect = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            for object in assets {
                object.fetchOriginalImageWithCompleteBlock { (image, info) -> Void in
                    //convert photo to string and clean it
                    let uploadData: NSData = UIImageJPEGRepresentation(image!, 0.05)!
                    let fileString: String = uploadData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                    let subString = md5(string: fileString)
                    self.avatarImageId = subString
                    object.fetchOriginalImageWithCompleteBlock { (image, info) -> Void in
                        //convert photo to string and clean it
                        self.group?.avatar = image
                        self.avatarImage.image = image
                    }

                }
            }

        }
        self.presentViewController(pickerController, animated: true) {}    
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender === nextButton {
            let name = groupTextField.text ?? ""
            let id = groupTextField.text ?? ""
            let avatar = avatarImage.image
            let update = "placehodlertoavoiderror"
            group = Group(id: id, name: name, avatar: avatar, update: update)
            
            let svc = segue.destinationViewController as! AddGroupMembersTableViewController;
            svc.group = self.group
            svc.avatarImageId = self.avatarImageId
        }
    }
    
}
