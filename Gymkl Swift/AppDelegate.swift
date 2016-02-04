//
//  AppDelegate.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 07.06.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

//  This file is used for configuring the behaviour when starting/terminating the app and other status changes

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    override init() {
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // This is executed when the application is starting
        
        // Loading previously saved defaults (Bus stations to be loaded, settings from "More"-Tab
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultDict)
        stationsToLoad = NSUserDefaults.standardUserDefaults().objectForKey("stations")! as! Array<Int>
        NSUserDefaults.standardUserDefaults().setObject((NSUserDefaults.standardUserDefaults().objectForKey("numberOfLaunches")! as! Int) + 1, forKey: "numberOfLaunches")
        
//        // Order bus station names from raw data
//        for (letter, stations) in fullStationArray {
//            var tempNames = [String]()
//            for (name, id) in stations {
//                stationsByNames[name] = id
//                stationsByKeys[id] = name
//                tempNames.append(name)
//            }
//            stationNames[letter] = tempNames.sort(<)
//        }
//        stationIndexes = stationIndexes.sort(<)
//        stationNamesArray = stationsByKeys.values.sort(<)
        
        // Set animation behaviour for "Mensa"-Tab according to user preferences or default
        // Default is to disable animations after 4 launches as to not clutter the workflow
        if ((NSUserDefaults.standardUserDefaults().objectForKey("numberOfLaunches")! as! Int) < 4) {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "mensaAnimation")
        }
            
        else if (NSUserDefaults.standardUserDefaults().objectForKey("mensaAnimationOverridden")! as! Bool) == false {
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "mensaAnimation")
        }
        
        // This makes sure all defaults are saved after making changes
        NSUserDefaults.standardUserDefaults().synchronize()
        
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSUserDefaults.standardUserDefaults().synchronize()
    }


}

