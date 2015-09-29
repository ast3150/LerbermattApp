//
//  BusTableViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This class manages the basic "Bus"-Tab view that displays the next departures

import UIKit
import Foundation

class BusTableViewController: UITableViewController {

    // Variables
    var actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var busData = NSMutableData()
    var jsonError: NSError?
    var networkErrorView = UIViewController()
    var noDataErrorView = UIViewController()
    var showingNetworkErrorView = false
    var showingNoDataErrorView = false
    var stationArray = [String: Station]()
    var reloadTimer = NSTimer()
    
    // Outlets
    @IBOutlet var busTableView: UITableView!
    
    // MARK: -
    override func viewWillAppear(animated: Bool) {
        networkErrorView = storyboard!.instantiateViewControllerWithIdentifier("NetworkErrorView") as UIViewController
        noDataErrorView = storyboard!.instantiateViewControllerWithIdentifier("NoDataErrorView") as UIViewController
        self.loadData()
    }

    // MARK: - Loading and Reloading
    @IBAction func refreshPressed(sender: AnyObject) {
        self.loadData()
    }
    
    func showReloadIndicators() {
        app.networkActivityIndicatorVisible = true
        self.navigationItem.leftBarButtonItem?.customView = actInd
        actInd.startAnimating()
    }
    
    func hideReloadIndicators(showNetworkErrorView showNetworkErrorView: Bool, showNoDataErrorView: Bool) {
        let reloadButton  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshPressed:")
        if showNetworkErrorView && !showingNetworkErrorView {
            self.navigationController!.pushViewController(networkErrorView, animated: false)
            networkErrorView.navigationItem.hidesBackButton = true
            networkErrorView.navigationItem.leftBarButtonItem = reloadButton
            networkErrorView.navigationItem.title = "Fahrplan"
            showingNetworkErrorView = true
        }
        else if !showNetworkErrorView && showingNetworkErrorView {
            self.navigationController?.popToRootViewControllerAnimated(false)
            showingNetworkErrorView = false
        }
        if showNoDataErrorView && !showingNoDataErrorView {
            self.navigationController!.pushViewController(noDataErrorView, animated: false)
            noDataErrorView.navigationItem.hidesBackButton = true
            noDataErrorView.navigationItem.leftBarButtonItem = reloadButton
            noDataErrorView.navigationItem.title = "Fahrplan"
            showingNoDataErrorView = true
        }
        else if !showNoDataErrorView && showingNoDataErrorView {
            self.navigationController?.popToRootViewControllerAnimated(false)
            showingNoDataErrorView = false
        }
        app.networkActivityIndicatorVisible = false
        actInd.stopAnimating()
        self.navigationItem.leftBarButtonItem = reloadButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.blackColor()
    }

}

struct Station {
    var departures = [Departure]()
    var loadingURL = NSURL()
    var stationName = ""
    var requestTime = ""
}

struct Departure {
    var link = ""
    var linkURL = NSURL()
    var late = false
    var departure = ""
    var line = ""
    var time = ""
    var direction = ""
}

// MARK: - Networking
extension BusTableViewController: NSURLSessionDataDelegate {

    func loadData() { // This method controls the process of loading and parsing JSON Data
        if reloadTimer.valid {
            // If reloadTimer is still running, disable it to avoid multiple reloads
            reloadTimer.invalidate()
        }
        self.showReloadIndicators()
        stationArray.removeAll(keepCapacity: false)
        
        for urlString in stationsToLoad {
            // Reset data objects
            busData.length = 0
            jsonError = nil
            
            var request = NSURLRequest(URL: NSURL(string: "http://m.mezi.ch/timetable/json/\(urlString)")!)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
                if response != nil {
                    if let error = self.jsonError {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: true)
                        })
                    }
                    else if (response as! NSHTTPURLResponse).statusCode == 200 && data!.length != 0 {
                        var string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        var jsonDepartureDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &self.jsonError) as Dictionary<String, AnyObject>
                        self.parseJSON(jsonDepartureDictionary) // Extracts data from JSON Array
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: false)
                            self.tableView.reloadData()
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.hideReloadIndicators(showNetworkErrorView: true, showNoDataErrorView: false)
                        })
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideReloadIndicators(showNetworkErrorView: true, showNoDataErrorView: false)
                    })
                }
            })
            task.resume()
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("loadData"), userInfo: nil, repeats: false) // Reload data after 30 seconds
    }

    
    func parseJSON(dict: Dictionary<String,AnyObject>) {
        var protoStation = Station()
        protoStation.stationName = dict["header"] as AnyObject? as! String
        protoStation.requestTime = dict["requestTime"] as AnyObject? as! String
        for object in dict["departures"] as AnyObject? as! Array<Dictionary<String, String>> {
            var protoDeparture = Departure()
            protoDeparture.time = object["time"]!
            protoDeparture.line = object["line"]!
            protoDeparture.link = object["direction_href"]!
            protoDeparture.direction = object["direction"]!
            protoDeparture.departure = object["departure"]!
            protoDeparture.departure = protoDeparture.departure.stringByReplacingOccurrencesOfString("min", withString: " min", options: nil, range: nil)
            var lateString = object["late"]!
            if lateString == "false" {
                protoDeparture.late = false
            }
            else if lateString == "true" {
                protoDeparture.late = true
            }
            protoStation.departures.append(protoDeparture)
        }
        var stationString = protoStation.stationName.stringByReplacingOccurrencesOfString(",", withString: "", options: [], range: nil)
        stationArray[stationString] = protoStation
    }
}


extension BusTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // This returns the number of sections (one for each station)
        return stationArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the number of rows in each section (3 is default, also handles if there are less available)
        if let station = stationArray[stationsByKeys[stationsToLoad[section]]!] {
            if station.departures.count >= 3 {
                return 3
            }
            else {
                return station.departures.count
            }
        }
        else {
            // If there is no data, return 1 that can be filled with "Daten nicht verfügbar"
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "StationID")
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        cell.textLabel!.font = UIFont.systemFontOfSize(13.0)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(13.0)
        // Fill cell with appropriate info (line destination, time to departure)
        if let station = stationArray[stationsByKeys[stationsToLoad[indexPath.section]]!] {
            cell.textLabel!.text = station.departures[indexPath.row].direction
            cell.detailTextLabel?.text = station.departures[indexPath.row].departure
            for character in (cell.detailTextLabel!.text!).characters {
                if character == "h" {
                    // If departure time is more than 60 minutes from now, display static time (hh:mm)
                    cell.detailTextLabel?.text = station.departures[indexPath.row].time
                    break;
                }
            }
            if station.departures[indexPath.row].late == true {
                cell.detailTextLabel?.textColor = .redColor()
            }
        }
        else {
            cell.textLabel!.text = "Daten nicht verfügbar"
        }
        
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            dispatch_async(dispatch_get_main_queue(), {
                self.hideReloadIndicators(showNetworkErrorView: false, showNoDataErrorView: false)
            })
        }
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        // Fills section titles (station names)
        if let station = stationArray[stationsByKeys[stationsToLoad[section]]!] {
            return station.stationName
        }
        else {
            return stationsByKeys[stationsToLoad[section]]!
        }
    }
}



// MARK: - Navigation
protocol BusEditViewControllerDelegate {
    // This is called when BusEditViewController finishes, to initiate animations etc.
    func busEditViewControllerDidSave(controller: BusEditViewController)
}

extension BusTableViewController: BusEditViewControllerDelegate {
    
    @IBAction func showEdit(sender: AnyObject) {
        // Called when user presses "Edit" to show BusEditViewController
        var editViewController = storyboard?.instantiateViewControllerWithIdentifier("BusEditViewController") as! BusEditViewController
        editViewController.delegate = self
        var editNavigationController = UINavigationController(rootViewController: editViewController)
        editNavigationController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        editNavigationController.navigationBar.barTintColor = yellowColor
        editViewController.navigationItem.title = "Stationen"
        editViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: editViewController, action: Selector("showAdd:"))
        editViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: editViewController, action: Selector("dismissEdit:"))
        self.presentViewController(editNavigationController, animated: true, completion: nil)
    }    
    
    func busEditViewControllerDidSave(controller: BusEditViewController) {
        self.navigationController!.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.loadData()
    }
}