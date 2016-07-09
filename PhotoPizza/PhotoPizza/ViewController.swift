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


class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    // MARK: Properties
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {}
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {}
    
    func configureFacebook()
    {
        loginButton.readPermissions = ["public_profile", "email", "user_friends"];
        loginButton.delegate = self
    }
    


}

