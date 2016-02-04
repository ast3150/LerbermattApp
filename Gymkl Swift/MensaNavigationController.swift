//
//  MensaNavigationController.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 06.08.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

import Foundation
import UIKit

class MensaNavigationController: UINavigationController {

    required init(coder aDecoder: NSCoder!) {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navBar.barTintColor = UIColor.blackColor()
        //tabItem.selectedImage = UIImage(named: "MensaIconFilled")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}