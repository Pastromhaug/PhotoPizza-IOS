//
//  Group.swift
//  photopizza
//
//  Created by Gary Cheng on 7/11/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
class Group {
    var id: String
    var name: String
    var avatar: UIImage?
    var members: [String]
    var update: String
    
    init(id: String, name: String, avatar: UIImage?, update: String) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.members = [String]()
        self.update = update
    }
    
    init(id: String, name: String, avatar: UIImage?) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.members = [String]()
        self.update = ""
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.avatar = UIImage(named: "noAvatar")
        self.members = [String]()
        self.update = ""
    }

    func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Group {
            return self.name == object.name
        } else {
            return false
        }
    }
    
    var hash: Int {
        return name.hashValue
    }
}
