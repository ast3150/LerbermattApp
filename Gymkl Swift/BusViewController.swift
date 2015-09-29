//
//  BusViewController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  Controls navigation in "Bus"-Tab

import UIKit
import Foundation

class BusNavigationController: UINavigationController {
    
    // Variable definition
    var navBar = UINavigationBar()
    var navItem = UINavigationItem()
    var busEditViewController = BusEditViewController()
    var busTableViewController = BusTableViewController()
    var busAddViewController = BusAddViewController()
    
    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Selected)
    }
}