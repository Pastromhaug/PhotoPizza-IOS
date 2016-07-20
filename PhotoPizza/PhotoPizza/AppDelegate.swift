//
//  AppDelegate.swift
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
var ref: FIRDatabaseReference? = nil

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        ref = FIRDatabase.database().reference()
        ref!.keepSynced(true)
        
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.        UIApplication.sharedApplication().statusBarStyle = .LightContent
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        print("access token1: \(FBSDKAccessToken.currentAccessToken()) ")
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            verifyAndLaunch(FBSDKAccessToken.currentAccessToken())
        }
        else {
            self.goToView("loginPage")
            print("firebase error 1")
        }
        return true
    }
    
    func verifyAndLaunch(fbToken: FBSDKAccessToken) {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(fbToken.tokenString)
        print("authData:")
        if let user: FIRUser? = FIRAuth.auth()?.currentUser {
            print("user signed in")
            self.getUserDataAndSwitchViews(user, view: "newNav")
        } else {
            print("user not signed in")
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                if (error != nil) {
                    print("FIREBASE SIGN IN ERROR")            }
                else {
                    print("firebase sign in working")
                    self.getUserDataAndSwitchViews(user, view: "newNav")
                }
            }
        }
        
        

    }
    
    func getUserDataAndSwitchViews(user: FIRUser?, view: String) {
        if let userRef: FIRDatabaseReference? =
            FIRDatabase.database().reference().child("users").child(user!.uid) {
                userRef!.observeSingleEventOfType(.Value,
                                                  withBlock: { snapshot in
                                                    let userInfo = JSON(snapshot.value!)
                                                    let userName = userInfo["userName"].stringValue
                                                    let userFacebookId = userInfo["facebookId"].intValue
                                                    let userEmail = userInfo["userEmail"].stringValue
                                                    let userFirebaseId = userInfo["firebaseId"].stringValue
                                                    var groups = [String:String]()
                                                    currentUser = User(name: userName, email: userEmail, facebookId: userFacebookId, groups: groups)
                                                    currentUser.firebaseId = userFirebaseId
                                                    self.goToView(view)
                    }
                )
        }
        else {
            print("failed to sign in to firebase")
        }

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an inc    oming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func goToView(view: String) {
        let storyBoard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = (storyBoard?.instantiateViewControllerWithIdentifier(view))! as UIViewController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = nextViewController
        self.window?.makeKeyAndVisible()
    }



}

