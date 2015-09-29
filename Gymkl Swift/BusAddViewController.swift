//
//  BusAddViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 03.09.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This class controls the View that is displayed when adding Bus stations.
//  It includes functions for displaying a Table View of all stations that can be searched and is indexed.
//  The Table View supports multiple selections


import Foundation
import UIKit

class BusAddViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    // MARK: Variables
    var selectedCells = [String]()
    var searchIndexes = stationIndexes
    var searchController: UISearchController!
    var delegate:BusAddViewControllerDelegate?

    // MARK: Outlets
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Runtime functions
    override func viewDidLoad() {
        
        // Configure tableView
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "AddID")
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)
        
        // Initialize searchController
        searchController = UISearchController(searchResultsController: nil)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
}

extension BusAddViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Sets the number of sections depending if any input has been done in the search text field or not
        if searching {
            if searchArray != [] {
                return 1
            }
            return 0
        }
        return searchIndexes.count
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        // Determines the number of rows in each section of the table view
        if searching {
            return searchArray.count
        }
        return fullStationArray[stationIndexes[section]]!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configures each cell of the table view
        let cell = tableView.dequeueReusableCellWithIdentifier("AddID", forIndexPath: indexPath) as UITableViewCell
        if searching {
            cell.textLabel!.text = searchArray[indexPath.row]
        }
        else {
            cell.textLabel!.text = stationNames[stationIndexes[indexPath.section]]![indexPath.row]
        }
        if selectedCells.contains(cell.textLabel!.text!) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Manages the selection and deselection of cells. Selected cells are added to the selectedCells array
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let id = stationsByNames[cell.textLabel!.text!]!
        
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            // Select cell
            cell.accessoryType = .Checkmark
            stationsToLoad.append(id)
            NSUserDefaults.standardUserDefaults().setObject(stationsToLoad, forKey: "stations")
            selectedCells.append(cell.textLabel!.text!)
        }
        else if cell.accessoryType == .Checkmark {
            // Deselect cell
            cell.accessoryType = .None
            stationsToLoad = stationsToLoad.filter({$0 != stationsByNames[cell.textLabel!.text!]})
            NSUserDefaults.standardUserDefaults().setObject(stationsToLoad, forKey: "stations")
            selectedCells = selectedCells.filter() {$0 != cell.textLabel!.text}
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        // Returns the title of the section, e.g. "A", "B", "C"
        if !searching {
            return searchIndexes[section]
        }
        return ""
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String] {
        // Returns the letters for the indexes (side bar displaying letters for quick access)
        if !searching {
            return [UITableViewIndexSearch] + searchIndexes
        }
        return []
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        // When the user is choosing from the index bar, scrolls to appropriate position
        if !searching {
            if title == UITableViewIndexSearch {
                tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
                return -1
            }
            return searchIndexes.indexOf(title)!
        }
        return 0
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        var searchText = searchBar.text
        if searchText == "" || searchText == nil {
            searching = false
            searchArray = stationNamesArray
            searchIndexes = stationIndexes
            self.tableView.reloadData()
        }
        else {
            searching = true
            searchArray.removeAll(keepCapacity: false)
            searchIndexes = [""]
            searchArray = stationNamesArray.filter() { (string: String) -> Bool in return
                NSString(string: string.lowercaseString).containsString(searchText!.lowercaseString)
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.updateSearchResultsForSearchController(searchController)
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        self.updateSearchResultsForSearchController(searchController)
    }
}

// MARK: Navigation
extension BusAddViewController {
    @IBAction func dismissAdd(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        delegate?.busAddViewControllerDidSave(self)
    }

    override func viewWillDisappear(animated: Bool) {
    }
}