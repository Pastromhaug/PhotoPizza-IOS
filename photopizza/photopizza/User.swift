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
    var id: Int
    var groups: [String]
    
    init() {
        self.name = ""
        self.email = ""
        self.id = 0
        self.groups = [String]()
    }
    
    init(name: String, email: String, id: Int, groups: [String]) {
        self.name = name
        self.email = email
        self.id = id
        self.groups = groups
    }
}
