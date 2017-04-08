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
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var isMoreDataLoading = false
    var currentOffset = 0
    
    var currentSearchText = "Restaurants"
    var selectedCategories: [String]!
    
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
        
        Business.searchWithTerm(term: currentSearchText, offset: offset, sort: nil, categories: selectedCategories, deals: nil) { (businesses:[Business]?, error: Error?) -> Void in
            if self.isMoreDataLoading && (businesses != nil) {
                self.businesses.append(contentsOf: businesses!)
                self.isMoreDataLoading = false
            } else {
                self.businesses = businesses
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
    
    // MARK: - FiltersViewController methods
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        selectedCategories = filters["categories"] as? [String]
        currentOffset = 0
        reloadResults()
    }
    
    // MARK: - Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }

    // MARK: - Table view data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
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
                currentOffset += 1
                reloadResults()
            }
        }
    }
}
