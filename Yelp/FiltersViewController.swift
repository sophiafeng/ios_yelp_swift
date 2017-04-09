//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Sophia on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController,
        didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, DealCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    // Categories dictionary and switch sttaes
    var categories: [[String:String]]!
    var switchStates = [Int:Bool]()
    var expandAllCategories = false
    
    // Filter by deals flag
    var filterDeals = false
    
    // Distance dictionary and display all flag
    var displayAllDistances = false
    var selectedDistance = YelpDistanceMode.BestMatch.rawValue
    
    // Sort
    var displayAllSorts = false
    var selectedSort = YelpSortMode.BestMatched.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {  // Deals filter section
            return "Deals"
        } else if section == 1 { // Distances filter
            return "Distance"
        } else if section == 2 { // Sort by section
            return "Sort"
        } else {  // Categories filter section
            return "Categories"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {  // Deals filter section
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath) as! DealCell
            cell.dealLabel.text = "Offering a Deal"
            cell.delegate = self
            cell.dealSwitch.isOn = filterDeals
            return cell
        } else if indexPath.section == 1 {  // Distances section
            let cell = tableView.dequeueReusableCell(withIdentifier: "DistanceCell", for: indexPath) as! DistanceCell
            if indexPath.row == 0 {
                if displayAllDistances {
                    cell.dropDownImage.image = #imageLiteral(resourceName: "arrowdown")
                } else {
                    cell.dropDownImage.image = #imageLiteral(resourceName: "arrowleft")
                }
                cell.distanceLabel.text = yelpDistances()[selectedDistance]
            } else {
                cell.distanceLabel.text = yelpDistances()[indexPath.row]
            }
            return cell
        } else if indexPath.section == 2 {  // Sort section
            let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as! SortCell
            if indexPath.row == 0 {
                if displayAllSorts {
                    cell.dropDownImage.image = #imageLiteral(resourceName: "arrowdown")
                } else {
                    cell.dropDownImage.image = #imageLiteral(resourceName: "arrowleft")
                }
                cell.sortLabel.text = yelpSorts()[selectedSort]
            } else {
                cell.sortLabel.text = yelpSorts()[indexPath.row]
            }
            return cell
        } else {  // Categories section
            if !expandAllCategories && indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell.textLabel?.text = "See All"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.delegate = self
                cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {  // Distances section
            if indexPath.row == 0 {
                displayAllDistances = !displayAllDistances
                selectedDistance = YelpDistanceMode.BestMatch.rawValue
                if !displayAllDistances {
                    selectedDistance = indexPath.row
                }
                tableView.reloadData()
                return
            }
            
            if displayAllDistances {
                selectedDistance = indexPath.row
            }
            
            displayAllDistances = !displayAllDistances
            tableView.reloadData()
        } else if indexPath.section == 2 {  // sort section
            if indexPath.row == 0 {
                displayAllSorts = !displayAllSorts
                selectedSort = YelpSortMode.BestMatched.rawValue
                if !displayAllSorts {
                    selectedSort = indexPath.row
                }
                tableView.reloadData()
                return
            }
            
            if displayAllSorts {
                selectedSort = indexPath.row
            }
            
            displayAllSorts = !displayAllSorts
            tableView.reloadData()
        } else if indexPath.section == 3 {  // categories section
            if !expandAllCategories && indexPath.row == 3 {
                expandAllCategories = !expandAllCategories
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // Deal section
            return 1
        } else if section == 1 {  // distances section
            return displayAllDistances ? 5 : 1
        } else if section == 2 {
            return displayAllSorts ? 3 : 1
        } else if section == 3 {  // Categories section
            if expandAllCategories {
                return categories.count
            }
            return 4
        }
        return 1
    }
    
    
    // MARK: - SwitchCellDelegate methods
    func switchCell(switchCell: SwitchCell, didChange value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        switchStates[indexPath.row] = value
    }
    
    // MARK: - DealCellDelegate methods
    func dealCell(dealCell: DealCell, didChange value: Bool) {
        filterDeals = value
    }
    
    // MARK: - Bar button actions
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        var filters = [String:AnyObject]()
        
        // Set selected categories in filters dict
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        // Set filter deal switch value in filters dict
        filters["deals"] = filterDeals as AnyObject
        
        // Set distance filter value in filters dict
        filters["distance"] = self.selectedDistance as AnyObject
        
        // Set sort value in filters dict
        filters["sort"] = self.selectedSort as AnyObject
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    // MARK: Utility function for category name and API code
    func yelpCategories() -> [[String:String]] {
        return   [["name" : "Afghan", "code": "afghani"],
                  ["name" : "African", "code": "african"],
                  ["name" : "American, New", "code": "newamerican"],
                  ["name" : "American, Traditional", "code": "tradamerican"],
                  ["name" : "Arabian", "code": "arabian"],
                  ["name" : "Argentine", "code": "argentine"],
                  ["name" : "Armenian", "code": "armenian"],
                  ["name" : "Asian Fusion", "code": "asianfusion"],
                  ["name" : "Asturian", "code": "asturian"],
                  ["name" : "Australian", "code": "australian"],
                  ["name" : "Austrian", "code": "austrian"],
                  ["name" : "Baguettes", "code": "baguettes"],
                  ["name" : "Bangladeshi", "code": "bangladeshi"],
                  ["name" : "Barbeque", "code": "bbq"],
                  ["name" : "Basque", "code": "basque"],
                  ["name" : "Bavarian", "code": "bavarian"],
                  ["name" : "Beer Garden", "code": "beergarden"],
                  ["name" : "Beer Hall", "code": "beerhall"],
                  ["name" : "Beisl", "code": "beisl"],
                  ["name" : "Belgian", "code": "belgian"],
                  ["name" : "Bistros", "code": "bistros"],
                  ["name" : "Black Sea", "code": "blacksea"],
                  ["name" : "Brasseries", "code": "brasseries"],
                  ["name" : "Brazilian", "code": "brazilian"],
                  ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                  ["name" : "British", "code": "british"],
                  ["name" : "Buffets", "code": "buffets"],
                  ["name" : "Bulgarian", "code": "bulgarian"],
                  ["name" : "Burgers", "code": "burgers"],
                  ["name" : "Burmese", "code": "burmese"],
                  ["name" : "Cafes", "code": "cafes"],
                  ["name" : "Cafeteria", "code": "cafeteria"],
                  ["name" : "Cajun/Creole", "code": "cajun"],
                  ["name" : "Cambodian", "code": "cambodian"],
                  ["name" : "Canadian", "code": "New)"],
                  ["name" : "Canteen", "code": "canteen"],
                  ["name" : "Caribbean", "code": "caribbean"],
                  ["name" : "Catalan", "code": "catalan"],
                  ["name" : "Chech", "code": "chech"],
                  ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                  ["name" : "Chicken Shop", "code": "chickenshop"],
                  ["name" : "Chicken Wings", "code": "chicken_wings"],
                  ["name" : "Chilean", "code": "chilean"],
                  ["name" : "Chinese", "code": "chinese"],
                  ["name" : "Comfort Food", "code": "comfortfood"],
                  ["name" : "Corsican", "code": "corsican"],
                  ["name" : "Creperies", "code": "creperies"],
                  ["name" : "Cuban", "code": "cuban"],
                  ["name" : "Curry Sausage", "code": "currysausage"],
                  ["name" : "Cypriot", "code": "cypriot"],
                  ["name" : "Czech", "code": "czech"],
                  ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                  ["name" : "Danish", "code": "danish"],
                  ["name" : "Delis", "code": "delis"],
                  ["name" : "Diners", "code": "diners"],
                  ["name" : "Dumplings", "code": "dumplings"],
                  ["name" : "Eastern European", "code": "eastern_european"],
                  ["name" : "Ethiopian", "code": "ethiopian"],
                  ["name" : "Fast Food", "code": "hotdogs"],
                  ["name" : "Filipino", "code": "filipino"],
                  ["name" : "Fish & Chips", "code": "fishnchips"],
                  ["name" : "Fondue", "code": "fondue"],
                  ["name" : "Food Court", "code": "food_court"],
                  ["name" : "Food Stands", "code": "foodstands"],
                  ["name" : "French", "code": "french"],
                  ["name" : "French Southwest", "code": "sud_ouest"],
                  ["name" : "Galician", "code": "galician"],
                  ["name" : "Gastropubs", "code": "gastropubs"],
                  ["name" : "Georgian", "code": "georgian"],
                  ["name" : "German", "code": "german"],
                  ["name" : "Giblets", "code": "giblets"],
                  ["name" : "Gluten-Free", "code": "gluten_free"],
                  ["name" : "Greek", "code": "greek"],
                  ["name" : "Halal", "code": "halal"],
                  ["name" : "Hawaiian", "code": "hawaiian"],
                  ["name" : "Heuriger", "code": "heuriger"],
                  ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                  ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                  ["name" : "Hot Dogs", "code": "hotdog"],
                  ["name" : "Hot Pot", "code": "hotpot"],
                  ["name" : "Hungarian", "code": "hungarian"],
                  ["name" : "Iberian", "code": "iberian"],
                  ["name" : "Indian", "code": "indpak"],
                  ["name" : "Indonesian", "code": "indonesian"],
                  ["name" : "International", "code": "international"],
                  ["name" : "Irish", "code": "irish"],
                  ["name" : "Island Pub", "code": "island_pub"],
                  ["name" : "Israeli", "code": "israeli"],
                  ["name" : "Italian", "code": "italian"],
                  ["name" : "Japanese", "code": "japanese"],
                  ["name" : "Jewish", "code": "jewish"],
                  ["name" : "Kebab", "code": "kebab"],
                  ["name" : "Korean", "code": "korean"],
                  ["name" : "Kosher", "code": "kosher"],
                  ["name" : "Kurdish", "code": "kurdish"],
                  ["name" : "Laos", "code": "laos"],
                  ["name" : "Laotian", "code": "laotian"],
                  ["name" : "Latin American", "code": "latin"],
                  ["name" : "Live/Raw Food", "code": "raw_food"],
                  ["name" : "Lyonnais", "code": "lyonnais"],
                  ["name" : "Malaysian", "code": "malaysian"],
                  ["name" : "Meatballs", "code": "meatballs"],
                  ["name" : "Mediterranean", "code": "mediterranean"],
                  ["name" : "Mexican", "code": "mexican"],
                  ["name" : "Middle Eastern", "code": "mideastern"],
                  ["name" : "Milk Bars", "code": "milkbars"],
                  ["name" : "Modern Australian", "code": "modern_australian"],
                  ["name" : "Modern European", "code": "modern_european"],
                  ["name" : "Mongolian", "code": "mongolian"],
                  ["name" : "Moroccan", "code": "moroccan"],
                  ["name" : "New Zealand", "code": "newzealand"],
                  ["name" : "Night Food", "code": "nightfood"],
                  ["name" : "Norcinerie", "code": "norcinerie"],
                  ["name" : "Open Sandwiches", "code": "opensandwiches"],
                  ["name" : "Oriental", "code": "oriental"],
                  ["name" : "Pakistani", "code": "pakistani"],
                  ["name" : "Parent Cafes", "code": "eltern_cafes"],
                  ["name" : "Parma", "code": "parma"],
                  ["name" : "Persian/Iranian", "code": "persian"],
                  ["name" : "Peruvian", "code": "peruvian"],
                  ["name" : "Pita", "code": "pita"],
                  ["name" : "Pizza", "code": "pizza"],
                  ["name" : "Polish", "code": "polish"],
                  ["name" : "Portuguese", "code": "portuguese"],
                  ["name" : "Potatoes", "code": "potatoes"],
                  ["name" : "Poutineries", "code": "poutineries"],
                  ["name" : "Pub Food", "code": "pubfood"],
                  ["name" : "Rice", "code": "riceshop"],
                  ["name" : "Romanian", "code": "romanian"],
                  ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                  ["name" : "Rumanian", "code": "rumanian"],
                  ["name" : "Russian", "code": "russian"],
                  ["name" : "Salad", "code": "salad"],
                  ["name" : "Sandwiches", "code": "sandwiches"],
                  ["name" : "Scandinavian", "code": "scandinavian"],
                  ["name" : "Scottish", "code": "scottish"],
                  ["name" : "Seafood", "code": "seafood"],
                  ["name" : "Serbo Croatian", "code": "serbocroatian"],
                  ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                  ["name" : "Singaporean", "code": "singaporean"],
                  ["name" : "Slovakian", "code": "slovakian"],
                  ["name" : "Soul Food", "code": "soulfood"],
                  ["name" : "Soup", "code": "soup"],
                  ["name" : "Southern", "code": "southern"],
                  ["name" : "Spanish", "code": "spanish"],
                  ["name" : "Steakhouses", "code": "steak"],
                  ["name" : "Sushi Bars", "code": "sushi"],
                  ["name" : "Swabian", "code": "swabian"],
                  ["name" : "Swedish", "code": "swedish"],
                  ["name" : "Swiss Food", "code": "swissfood"],
                  ["name" : "Tabernas", "code": "tabernas"],
                  ["name" : "Taiwanese", "code": "taiwanese"],
                  ["name" : "Tapas Bars", "code": "tapas"],
                  ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                  ["name" : "Tex-Mex", "code": "tex-mex"],
                  ["name" : "Thai", "code": "thai"],
                  ["name" : "Traditional Norwegian", "code": "norwegian"],
                  ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                  ["name" : "Trattorie", "code": "trattorie"],
                  ["name" : "Turkish", "code": "turkish"],
                  ["name" : "Ukrainian", "code": "ukrainian"],
                  ["name" : "Uzbek", "code": "uzbek"],
                  ["name" : "Vegan", "code": "vegan"],
                  ["name" : "Vegetarian", "code": "vegetarian"],
                  ["name" : "Venison", "code": "venison"],
                  ["name" : "Vietnamese", "code": "vietnamese"],
                  ["name" : "Wok", "code": "wok"],
                  ["name" : "Wraps", "code": "wraps"],
                  ["name" : "Yugoslav", "code": "yugoslav"]]
    }
    
    // Distance name to distance in meters
    func yelpDistances() -> [Int: String] {
        return [
            YelpDistanceMode.BestMatch.rawValue: "Best Match",
            YelpDistanceMode.TwoBlocks.rawValue: "2 blocks",
            YelpDistanceMode.SixBlocks.rawValue: "6 blocks",
            YelpDistanceMode.OneMile.rawValue: "1 mile",
            YelpDistanceMode.FiveMiles.rawValue: "5 miles"
        ]
    }
    
    // Sort by index to name
    func yelpSorts() -> [Int: String] {
        return [
            YelpSortMode.BestMatched.rawValue: "Best Match",
            YelpSortMode.Distance.rawValue: "Distance",
            YelpSortMode.HighestRated.rawValue: "Highest rated"
        ]
    }

}
