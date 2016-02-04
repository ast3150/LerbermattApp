//
//  GLBusAddLocationTableViewController.swift
//  Lerbermatt
//
//  Created by Alain Stulz on 31.01.16.
//  Copyright © 2016 Alain Stulz. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class GLBusAddLocationTableViewController: UITableViewController {

    var fetchedLocations = [AddLocationSearchResult]()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if let navigationController = self.navigationController as? GLBusNavigationController {
            navigationController.locationManager.requestLocation()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "AddLocationSearchResultCell")
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSearchResultsFromNotification:", name: "GLDidGetLocationsData", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.fetchedLocations.removeAll(keepCapacity: false)
    }

    // MARK: - Table view data source
    
    func updateSearchResultsFromNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            if let stations = json["stations"].arrayObject {
                fetchedLocations.removeAll(keepCapacity: false)
                for station in stations {
                    if let searchResult = AddLocationSearchResult(json: JSON(station)) {
                        let insertionIndex = fetchedLocations.insertionIndexOf(searchResult) {$0.score > $1.score}
                        fetchedLocations.insert(searchResult, atIndex: insertionIndex)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print(fetchedLocations.count > 0 ? 1 :0)
        return fetchedLocations.count > 0 ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(fetchedLocations.count)
        return fetchedLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddLocationSearchResultCell", forIndexPath: indexPath)
        cell.textLabel?.text = fetchedLocations[indexPath.row].name
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GLBusAddLocationTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        GLBusAPI.sharedInstance.getLocationsForQuery(searchText, withType: .Station)
    }
}


extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var minIndex = 0
        var maxIndex = self.count - 1
        while minIndex <= maxIndex {
            let midIndex = (minIndex + maxIndex)/2
            // Check if element is in first or second half
            if isOrderedBefore(self[midIndex], elem) {
                minIndex = midIndex + 1
            } else if isOrderedBefore(elem, self[midIndex]) {
                maxIndex = midIndex - 1
            } else {
                return midIndex // Found at position midIndex
            }
        }
        return minIndex // Not found, insert at 0
    }
}