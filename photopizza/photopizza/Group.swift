//
//  Group.swift
//  photopizza
//
//  Created by Gary Cheng on 7/11/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
class Group {
    var name: String
    var avatar: UIImage?
    var members: [String]
    
    init(name: String, avatar: UIImage?) {
        self.name = name
        self.avatar = avatar
        self.members = [String]()
    }
}
