//
//  BusEditViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 26.08.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  View for editing the stations

import Foundation
import UIKit

class BusEditViewController: UITableViewController {
    
    // MARK: Variables
    var delegate:BusEditViewControllerDelegate?
    
    // MARK: - Runtime Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "EditID")
        self.tableView.reloadData()
        if (stationsToLoad.count > 1) {
            self.tableView.setEditing(true, animated: false)
        }
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return stationsToLoad.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell...
        var cell = tableView.dequeueReusableCellWithIdentifier("EditID", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = stationsByKeys[stationsToLoad[indexPath.row]]
        return cell
    }
    
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        // Controls the deletion of cells
        if editingStyle == .Delete {
            if (stationsToLoad.count > 1) {
                stationsToLoad.removeAtIndex(indexPath!.row)
                NSUserDefaults.standardUserDefaults().setObject(stationsToLoad, forKey: "stations")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                if (stationsToLoad.count == 1) {
                    self.tableView.setEditing(false, animated: true)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {
        // Controls rearranging cells
        let tempObj = stationsToLoad[fromIndexPath!.row]
        stationsToLoad.removeAtIndex(fromIndexPath!.row)
        stationsToLoad.insert(tempObj, atIndex: toIndexPath!.row)
        NSUserDefaults.standardUserDefaults().setObject(stationsToLoad, forKey: "stations")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Makes sure that cells can only be deleted if there are more than two cells
        if (stationsToLoad.count > 1) {
            return true
        }
        else {
            tableView?.setEditing(false, animated: true)
            return false
        }
    }
}

// MARK: - Navigation

protocol BusAddViewControllerDelegate {
    // Is called when the user presses "Done" in BusAddViewController
    func busAddViewControllerDidSave(controller: BusAddViewController)
}

extension BusEditViewController: BusAddViewControllerDelegate {
    @IBAction func dismissEdit(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        delegate?.busEditViewControllerDidSave(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showAdd(sender: AnyObject) {
        // Called when user presses "+" to show BusAddViewController
        var addViewController = storyboard?.instantiateViewControllerWithIdentifier("BusAddViewController") as! BusAddViewController
        var addNavigationController = UINavigationController(rootViewController: addViewController)
        addViewController.delegate = self
        addNavigationController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        addNavigationController.navigationBar.barTintColor = yellowColor
        addNavigationController.navigationItem.title = "Hinzufügen"
        addViewController.navigationItem.leftBarButtonItem = nil
        addViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: addViewController, action: Selector("dismissAdd:"))
        self.presentViewController(addNavigationController, animated: true, completion: nil)
    }
    
    func busAddViewControllerDidSave(controller: BusAddViewController) {
        self.tableView.reloadData()
    }
}
