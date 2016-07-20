//
//  User.swift
//  vuepal
//
//  Created by Gary Cheng on 7/14/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit

class User {
    var name: String
    var email: String
    var facebookId: Int
    var firebaseId: String
    var groups: [String : String]
    
    init() {
        self.name = ""
        self.email = ""
        self.facebookId = 0
        self.firebaseId = ""
        self.groups = [String: String]()
    }
    
    init(name: String, email: String, facebookId: Int, groups: [String : String]) {
        self.name = name
        self.email = email
        self.facebookId = facebookId
        self.firebaseId = ""
        self.groups = groups
    }
}
