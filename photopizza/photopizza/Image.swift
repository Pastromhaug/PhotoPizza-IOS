//
//  Image.swift
//  vuepal
//
//  Created by Gary Cheng on 7/20/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit

class Image {
    var img : UIImage
    var imgId : String
    var uploadTimeSince1970 : Double
    var uploaderEmail : String
    var uploaderFacebookId : String
    var uploaderFirebaseId : String
    var uploaderName : String
    
    init(imgId : String, img: UIImage, uploadTimeSince1970: Double, uploaderEmail : String, uploaderFacebookId : String, uploaderFirebaseId : String, uploaderName : String) {
        self.imgId = imgId
        self.img = img
        self.uploadTimeSince1970 = uploadTimeSince1970
        self.uploaderEmail = uploaderEmail
        self.uploaderFacebookId = uploaderFacebookId
        self.uploaderFirebaseId = uploaderFirebaseId
        self.uploaderName = uploaderName
    }
    
    init(imgId : String, img: UIImage, uploadTimeSince1970: Double) {
        self.imgId = imgId
        self.img = img
        self.uploadTimeSince1970 = uploadTimeSince1970
        self.uploaderEmail = ""
        self.uploaderFacebookId = ""
        self.uploaderFirebaseId = ""
        self.uploaderName = ""
    }
    
    init(imgId : String, uploadTimeSince1970: Double) {
        self.imgId = imgId
        self.img = UIImage(named : "noAvatar")!
        self.uploadTimeSince1970 = uploadTimeSince1970
        self.uploaderEmail = ""
        self.uploaderFacebookId = ""
        self.uploaderFirebaseId = ""
        self.uploaderName = ""
    }
}
