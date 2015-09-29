//
//  MoreViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 23.09.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This class controls the "More"-Tab. It mainly processes the input from the settings controls.

import UIKit

class MoreViewSettingsTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    // MARK: - Runtime functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets controls to previously saved values when showing the view
        segmentedControl.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().objectForKey("launchTab")! as! Int
        animationSwitch.setOn((NSUserDefaults.standardUserDefaults().objectForKey("mensaAnimation")! as! Bool), animated: false)
    }
    
    @IBAction func selectedSegmentDidChange(sender: AnyObject) {
        
        // Changes the saved value for the tab that is selected when starting the app
        NSUserDefaults.standardUserDefaults().setObject(sender.selectedSegmentIndex, forKey: "launchTab")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func animationSwitchDidChange(sender: UISwitch) {
        
        // Changes the saved value that determines whether MensaView animations are used.
        // Default behaviour is turning off animations after the 4th launch.
        NSUserDefaults.standardUserDefaults().setObject(sender.on, forKey: "mensaAnimation")
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "mensaAnimationOverridden")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            app.openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id921371549")!)
        }
    }
}