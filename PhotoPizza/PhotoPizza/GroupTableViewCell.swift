//
//  GroupTableViewCell.swift
//  vuepal
//
//  Created by Per-Andre on 7/13/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
