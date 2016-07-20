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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        let tokenString = result.token.tokenString
        let fields = ["fields":"email,name,friendlists,permissions"]
        let req = FBSDKGraphRequest(graphPath: "me", parameters: fields, tokenString: tokenString, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil){
                let json = JSON(result)
                let name = json["name"].stringValue
                let facebookId = json["id"].intValue
                let email = json["email"].stringValue
                let groups = [String:String]()
                
                print("name: \(name)")
                print("id: \(facebookId)")
                print("email: \(email)")
                
                currentUser = User(name: name, email: email, facebookId: facebookId, groups: groups)
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    if (error != nil) {
                        print("FIREBASE SIGN IN ERROR")
                        print(error)
                    } else {
                        currentUser.firebaseId = user!.uid
                        let userRef = FIRDatabase.database().reference().child("users").child(currentUser.firebaseId)
                        let userDict: [String: AnyObject] = ["facebookId": String(currentUser.facebookId),
                            "firebaseId": currentUser.firebaseId,
                            "userName": currentUser.name,
                            "userEmail": currentUser.email]
                        userRef.updateChildValues(userDict)
                        isItDone = true
                        self.goToView("newNav")
                    }
                }
            } else{
                print("error \(error)")
            }
        })
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    func goToView(view: String) {
        let storyBoard : UIStoryboard? = self.storyboard
        let nextViewController = (storyBoard?.instantiateViewControllerWithIdentifier(view))! as UIViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
}

