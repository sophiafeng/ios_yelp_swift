//
//  BusinessCell.swift
//  Yelp
//
//  Created by Sophia on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var ratingsImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            businessImage.setImageWith(business.imageURL!)
            ratingsImage.setImageWith(business.ratingImageURL!)
            numReviewsLabel.text = "\(business.reviewCount!) reviews"
            distanceLabel.text = business.distance!
            addressLabel.text = business.address
            categoriesLabel.text = business.categories
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        businessImage.layer.cornerRadius = 5
        businessImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
