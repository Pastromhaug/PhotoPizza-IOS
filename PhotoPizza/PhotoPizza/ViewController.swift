//
//  ViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/9/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import SwiftyJSON

var currentUser : User = User()

var isItDone = false

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    // MARK: Properties
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var hoverBox: UIView!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    //@IBOutlet weak var mainBoxView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mainView.backgroundColor = UIColor(patternImage: UIImage(named: "loginBackground")!)
        self.hoverBox.layer.cornerRadius = self.hoverBox.frame.size.width / 16
        self.hoverBox.clipsToBounds = true
        self.hoverBox.backgroundColor = UIColor(white: 1, alpha: 0.3)
        
        loginButton.center = self.view.center
       // mainBoxView.center = self.view.center
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        FIRDatabase.database().persistenceEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // If you have user_likes permission granted
//        let connection = GraphRequestConnection()
//        connection.add(GraphRequest(graphPath: "me/likes")) { (response: NSHTTPURLResponse?, result: GraphRequestResult<GraphResponse>) in
//            // TODO: Process error or result.
//        }
//        connection.start()
    }
    

    
//    func configureFacebook() {
//        let fbLoginButton = FBSDKLoginButton()
//        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"];
//        fbLoginButton.delegate = self
//    }
//    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        
        print("Important: \(result.token.expirationDate)")
        print("Importnad: \(result.token.refreshDate)")
        
        let tokenString = result.token.tokenString
        let fields = ["fields":"email,name,friendlists,permissions"]
        let req = FBSDKGraphRequest(graphPath: "me", parameters: fields, tokenString: tokenString, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil){
                //print("result \(result)")
                print("making user")
                let json = JSON(result)
                let name = json["name"].stringValue
                let facebookId = json["id"].intValue
                let email = json["email"].stringValue
                
//                //TODO: make groups better
                var groups = [String:String]()
//                groups["hello"] = "hello"
//                groups["goodbye"] = "goodbye"
                
                print("name: \(name)")
                print("id: \(facebookId)")
                print("email: \(email)")
                
                currentUser = User(name: name, email: email, facebookId: facebookId, groups: groups)
               // print("THIS IS THE GORUP: \(currentUser.groups)")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    if (error != nil) {
                        print(error)
                    }
                    else {
                        currentUser.firebaseId = user!.uid
                        
                        
                        
                        let userRef = FIRDatabase.database().reference().child("users").child(currentUser.firebaseId)
                        let userDict: [String: AnyObject] = ["facebookId": String(currentUser.facebookId),
                            "firebaseId": currentUser.firebaseId,
                            "userName": currentUser.name,
                            "userEmail": currentUser.email]
                            //"groups": currentUser.groups]
                        userRef.updateChildValues(userDict)
                        //                self.initGroups()
                        //                self.dbListen()
                        isItDone = true
                        
                        let storyBoard : UIStoryboard? = self.storyboard
                        
                        let nextViewController = (storyBoard?.instantiateViewControllerWithIdentifier("newNav"))! as UIViewController
                        self.presentViewController(nextViewController, animated:true, completion:nil)
                        
                    }
                }


                
            }
            else{
                print("error \(error)")
            }
        })
        
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        
       
        //        let secondViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("home"))! as UIViewController
//        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
//    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.sourceViewController as? MealViewController, meal = sourceViewController.meal {
//            // Add a new meal.
//            let newIndexPath = NSIndexPath(forRow: meals.count, inSection: 0)
//            meals.append(meal)
//            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
//        }
//    }
    
//    // Listeners for the groups
//    func initGroups() {
//        //let groupRef = self.ref.child("groups")
//        //let curGroupRef = groupRef.child(self.navigationItem.title!)
//        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
//        //groups = [Group]()
//        let userGroupRef = ref.child("users/" + currentUser.firebaseId)
//        
//        print("THIS IS THE 93281740: \(currentUser.firebaseId)")
//        
//        
//        userGroupRef.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
//            //print("we made it here: \(self.navigationItem.title)")
//            let validGroups = JSON(snapshot.value!)["groups"]
//            //print(json)
//            //print("json count: \(json.count)")
//            //print (currentUser.groups)
//            for (group, _):(String, JSON) in validGroups {
//                
//                let validGroupRef = ref.child("groups/" + group)
//                validGroupRef.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
//                    let newDict = JSON(snapshot.value!)
//                    //print("HIGH: \(group)")
//                    //for (_, newDict):(String, JSON) in json {
//                    //if let newDict: JSON = allGroups[group] {
//                    let groupName = newDict["groupName"].stringValue
//                    let avatarImgId = newDict["avatarImgId"].stringValue
//                    
//                    let newGroup = Group(name: groupName, avatar: UIImage(named: "noAvatar"))
//                    groups.append(newGroup)
//                    newGroup.update = newDict["update"].stringValue ?? ""
//                    
//                    print("NEWVAL: \(groupName)")
//                    
//                    let photoRef = storageRef.child("images/" + avatarImgId)
//                    
//                    photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
//                        if (error != nil) {
//                            // Uh-oh, an error occurred!
//                            self.groupTableView.reloadData()
//                        } else {
//                            // Data for "images/island.jpg" is returned
//                            // ... let islandImage: UIImage! = UIImage(data: data!)
//                            newGroup.avatar = UIImage(data: data!)
//                            //self.loadView()
//                            
//                            self.groupTableView.reloadData()
//                            
//                        }
//                    }
//                    self.groupTableView.reloadData()
//                })
//            }
//        })
//        
//        
//    }
//    
//    func dbListen() {
//        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
//        //let postRef = FIRDatabase.database().reference().child("images")
//        
//        let userGroupRef = self.ref.child("users/" + currentUser.firebaseId + "/groups")
//        
//        userGroupRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
//            
//            let newDict = snapshot.value as! Dictionary<String, AnyObject>
//            print("HIGHLY IMPORTANT SHIT: \(newDict)")
//            for (groupAdded, _) in newDict {
//                let groupRef = self.ref.child("groups/" + groupAdded)
//                
//                groupRef.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
//                    
//                    let groupDict = snapshot.value as! Dictionary<String, AnyObject>
//                    let groupName = groupDict["groupName"] as! String
//                    for group in self.groups {
//                        if group.name == groupName{
//                            return
//                        }
//                    }
//                    let avatarImgId = groupDict["avatarImgId"] as! String ?? ""
//                    let newGroup = Group(name: groupName, avatar: UIImage(named: "noAvatar"))
//                    self.groups.append(newGroup)
//                    let photoRef = storageRef.child("images/" + avatarImgId)
//                    photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
//                        if (error != nil) {
//                            // Uh-oh, an error occurred!
//                            self.groupTableView.reloadData()
//                        } else {
//                            // Data for "images/island.jpg" is returned
//                            // ... let islandImage: UIImage! = UIImage(data: data!)
//                            newGroup.avatar = UIImage(data: data!)
//                            self.groupTableView.reloadData()
//                            
//                        }
//                    }
//                    self.groupTableView.reloadData()
//                    
//                })
//            }
//            
//            
//        })
//        userGroupRef.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
//            let newDict = snapshot.value as! Dictionary<String, AnyObject>
//            let groupName = newDict["groupName"] as! String
//            let len = self.groups.count
//            for i in 0..<len {
//                let curr = self.groups[i]
//                if (curr.name == groupName) {
//                    self.groups.removeAtIndex(i)
//                    self.groupTableView.reloadData()
//                    return
//                }
//            }
//            print(self.groups)
//        })
//    }
    
    

    
}

