//
//  SortCell.swift
//  Yelp
//
//  Created by Sophia on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class SortCell: UITableViewCell {

    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var dropDownImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
