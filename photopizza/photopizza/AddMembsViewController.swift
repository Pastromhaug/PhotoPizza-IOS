//
//  AddMembsViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/11/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import Firebase

class AddMembsViewController: UIViewController {
    let postRef = FIRDatabase.database().reference().child("groups")
    let databaseRef = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    var avatarImageId: String = ""
    var group: Group?
    
    var searchResults = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.group?.name)
        searchResults = ["Gary Chen, Per Andre Stromhaug, Paige, Anjali, Ken"]
        FIRDatabase.database().persistenceEnabled = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Action
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        let storageRef = self.storage.referenceForURL("gs://photo-pizza.appspot.com")
        let groupId = self.group!.name
        let groupRef = self.postRef.child(groupId)
        let dict:[String:String] = ["groupName": self.group!.name,
                    "creatorFacebookId": String(currentUser.facebookId),
                    "creatorFirebaseId": currentUser.firebaseId,
                    "update": "new group created by " + currentUser.name,
                    "avatarImgId": self.avatarImageId + ".jpg",
                    "groupId" : groupId]
        groupRef.updateChildValues(dict)
        
        let imgRef = storageRef.child("images/" + self.avatarImageId)
        let uploadData = UIImageJPEGRepresentation((self.group?.avatar!)!, 0.05)!
        imgRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            if (error != nil) {
                print("Error in putData")
            }
            else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                print("putData succeeded")
                let userGroupRef = self.databaseRef.child("users").child(currentUser.firebaseId).child("groups")
                
                let groupRef = self.databaseRef.child("groups")
                let curGroupRef = groupRef.child(self.group!.name)
                let curGroupImgRef = curGroupRef.child("images")
                
                //uploads to real time database
                var dict = [String: AnyObject]()
                dict["imgId"] = self.avatarImageId + ".jpg"
                dict["uploaderFirebaseId"] = currentUser.firebaseId
                dict["uploaderFacebookId"] = currentUser.facebookId
                dict["uploaderName"] = currentUser.name
                dict["uploaderEmail"] = currentUser.email
                dict["uploadTimeSince1970"] = NSDate().timeIntervalSince1970
                
                print("gucci\(dict)")
                curGroupImgRef.child(self.avatarImageId).updateChildValues(dict)
                var otherDict = [String: String]()
                otherDict[self.group!.name] = self.group!.name
                print("yolo\(otherDict)")
                
                userGroupRef.updateChildValues(otherDict)
                
            }
        })

        
        navigateToGroups()
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        navigateToGroups()
    }
    func navigateToGroups() {
        let storyBoard : UIStoryboard? = self.storyboard
        let nextViewController = (storyBoard?.instantiateViewControllerWithIdentifier("newNav"))! as UIViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
}
