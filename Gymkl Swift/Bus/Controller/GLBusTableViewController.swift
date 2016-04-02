//
//  GLBusTableViewController.swift
//  Lerbermatt
//
//  Created by Alain Stulz on 28.02.16.
//  Copyright © 2016 Alain Stulz. All rights reserved.
//

import UIKit
import SwiftyJSON

class STLocation: NSObject {
    let id: Int
    let name: String
    let stationboard: [STStationboardItem]?
    
    init(id: Int, name: String, stationboard: [STStationboardItem]?) {
        self.id = id
        self.name = name
        self.stationboard = stationboard
        super.init()
    }
}

class STStationboardItem: NSObject {
    let lineNumber: Int?
    let destination: String?
    let departure: NSDate
    
    init(lineNumber: Int?, destination: String?, departure: NSDate) {
        self.lineNumber = lineNumber
        self.departure = departure
        self.destination = destination
        super.init()
    }
}

class GLBusTableViewController: UITableViewController {

    var transport: SwiftyTransport
    var locations: [STLocation]?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.transport = SwiftyTransport()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transport.delegate = self
    }

    override init(style: UITableViewStyle) {
        self.transport = SwiftyTransport()
        super.init(style: style)
        transport.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.transport = SwiftyTransport()
        super.init(coder: aDecoder)
        transport.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try transport.getStationboardForID("008590100")
        } catch {
            // TODO: Catch
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

extension GLBusTableViewController: SwiftyTransportDelegate {
    func didGetConnectionsData(data: NSData) {
    }
    
    func didGetLocationsData(data: NSData) {
    }
    
    func didGetStationboardData(data: NSData) {
        let json = JSON(data: data)
        guard let stationID = json["station"]["id"].string else { return }
        if self.locations?.contains({$0.id == Int(stationID)}) {
            
        }
    }
    
    func didFailWithError(error: NSError?) {
    }
}
