//
//  AddMembsViewController.swift
//  photopizza
//
//  Created by Gary Cheng on 7/11/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit

class AddMembsViewController: UIViewController {

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
    
    
    
}
