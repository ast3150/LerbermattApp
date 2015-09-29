//
//  TabBarController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 23.09.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

// This class controls the Tab Bar.

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Select correct tab when launching app, according to user settings
        self.selectedIndex = NSUserDefaults.standardUserDefaults().objectForKey("launchTab") as! Int
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
