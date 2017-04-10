//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    let DEFAULT_RESULT_LIMIT = 20
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var isMoreDataLoading = false
    var currentOffset = 0
    
    var currentSearchText = "Restaurants"
    var selectedCategories: [String]!
    var filterDeals = false
    var sortByValue = 0
    var distanceValue = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120 // used to ball park a scroll height, when autolayout is calculating
        
        // Search bar set up
        searchBar = UISearchBar()
        searchBar.text = currentSearchText
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        reloadResults()
    }
    
    func reloadResults() {
        print("reloading results")
        var offset = 0
        if isMoreDataLoading {
            offset = currentOffset
        }
        
        Business.searchWithTerm(term: currentSearchText, offset: offset, limit: DEFAULT_RESULT_LIMIT, sort: YelpSortMode(rawValue: sortByValue), categories: selectedCategories, deals: filterDeals, distance: YelpDistanceMode(rawValue: distanceValue)) { (businesses:[Business]?, error: Error?) -> Void in
            
            if self.isMoreDataLoading && offset > 0 && (businesses != nil) {
                // Load more businesses
                self.businesses.append(contentsOf: businesses!)
                self.isMoreDataLoading = false
            } else if businesses != nil {
                // Set query results to current set of businesses
                self.businesses = businesses
            } else {
                // We are not loading more businesses and query results are nil
                self.businesses = []
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Search bar methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        currentOffset = 0
        reloadResults()
    }
    
    // MARK: - FiltersViewControllerDelegate methods
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        selectedCategories = filters["categories"] as? [String]
        filterDeals = (filters["deals"] as? Bool) ?? false
        distanceValue = (filters["distance"] as? Int) ?? YelpDistanceMode.BestMatch.rawValue
        sortByValue = (filters["sort"] as? Int) ?? YelpSortMode.BestMatched.rawValue
        currentOffset = 0
        reloadResults()
    }
    
    // MARK: - Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FiltersSegue" {
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        } else if segue.identifier == "DetailsSegue" {
            let detailsViewController = segue.destination as! DetailsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            detailsViewController.business = businesses[indexPath!.row]
        }
        
    }

    // MARK: - Table view data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil && businesses.count > 0 {
            return businesses.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if businesses != nil && businesses.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
            cell.business = businesses[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.textLabel?.text = "No results found!"
            return cell
        }
    }
    
    // MARK: - ScrollViewDelegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                currentOffset += DEFAULT_RESULT_LIMIT
                reloadResults()
            }
        }
    }
}
