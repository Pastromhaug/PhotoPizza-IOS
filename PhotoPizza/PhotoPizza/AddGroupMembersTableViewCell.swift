//
//  AddGroupMembersTableViewCell.swift
//  vuepal
//
//  Created by Per-Andre on 7/20/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit

class AddGroupMembersTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: Actions
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var subLabelOutlet: UILabel!
    //    @IBOutlet weak var labelOutlet: UILabel!
    //    @IBOutlet weak var imageOutlet: UIImageView!
    
}