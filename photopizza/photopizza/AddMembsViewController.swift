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

    var group: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.group?.name)
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
        let groupId = self.group!.name
        let groupRef = self.postRef.child(groupId)
        let dict:[String:String] = ["groupName": self.group!.name,
                    "creatorFacebookId": String(currentUser.facebookId),
                    "creatorFirebaseId": currentUser.firebaseId,
                    "update": "new group created by " + currentUser.name]
        groupRef.updateChildValues(dict)
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
