//
//  DetailsViewController.swift
//  Yelp
//
//  Created by Sophia on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var detailsMapView: MKMapView!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingsImage: UIImageView!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var business: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = business.name!
        if business.imageURL != nil {
            businessImage.setImageWith(business.imageURL!)
        } else {
            businessImage.image = #imageLiteral(resourceName: "yelp_icon")
        }
        ratingsImage.setImageWith(business.ratingImageURL!)
        numReviewsLabel.text = "\(business.reviewCount!) reviews"
        distanceLabel.text = business.distance!
        addressLabel.text = business.address
        categoriesLabel.text = business.categories
        
        if let latitude = business.latitude, let longitude = business.longitude {
            let loc = CLLocation(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegionMake(loc.coordinate, span)
            detailsMapView.setRegion(region, animated: false)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.title = business.name!
            detailsMapView.addAnnotation(annotation)
        }
    }
}
