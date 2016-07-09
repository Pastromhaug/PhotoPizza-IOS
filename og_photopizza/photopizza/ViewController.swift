//
//  ViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/9/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureFacebook()
    {
        btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
    }


}

