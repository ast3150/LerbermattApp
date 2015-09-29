//
//  Constants.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 27.08.14.
//  Copyright (c) 2014 Alain Stulz. All rights reserved.
//

// This file contains definitions for most of the constants and many variables used globally

import Foundation
import UIKit

// Colors
let blueColor = UIColor(red: (67/255), green: (178/255), blue: (226/255), alpha: 1.0) // "Mensa"-Tab Color (also see UI concept)
let greenColor = UIColor(red: 61/255, green: 174/255, blue: 124/255, alpha: 1.0) // "More"-Tab Color
let hairlineColor = UIColor(red: (200/255), green: (199/255), blue: (204/255), alpha: 1.0) // Color used for thin hairlines (e.g. between navigationBar and webView in "News"-Tab)
let redColor = UIColor(red: (247/255), green: (134/255), blue: (130/255), alpha: 1.0) // "News"-Tab Color
let turquoiseColor = UIColor(red: (63/255), green: (175/255), blue: (164/255), alpha: 1.0) // Previously used "Mensa-Tab" Color
let yellowColor = UIColor(red: (249/255), green: (229/255), blue: (29/255), alpha: 1.0) // "Bus"-Tab Color

// "Bus"-Tab Arrays and Dictionaries
var fullStationArray: [String: [String: Int]]  = NSDictionary(contentsOfFile: stationNamesPath!) as! Dictionary<String,Dictionary<String, Int>>
var stationsByNames: Dictionary<String, Int> = [String: Int]()
var stationsByKeys: Dictionary<Int, String> = [Int: String]()
var stationNames: Dictionary<String, Array<String>> = [String: [String]]()
var stationIndexes = [String](fullStationArray.keys)
var stationNamesArray = [String]()
var searchArray = [String]()
var searching = false

// Screen Dimensions
let screenHeight = UIScreen.mainScreen().bounds.size.height
let screenWidth = UIScreen.mainScreen().bounds.size.width

// URLs and paths
let newsBaseURL = NSURL(string: "http://gymkl-newsscraper.herokuapp.com")
let mensaBaseURL = NSURL(string: "http://gymkl-mensascraper.herokuapp.com")
let stationNamesPath = NSBundle.mainBundle().pathForResource("StationsByName", ofType: "plist") // Resource that contains all bus stations

// User defaults
var stationsToLoad: Array<Int> = [Int]()
var defaultDict: Dictionary<String, AnyObject> = ["stations" : [231, 6, 229, 5], "launchTab": 0, "numberOfLaunches": 0, "mensaAnimation": false, "mensaAnimationOverridden": false] // Default settings

// Others
let app = UIApplication.sharedApplication()
let horizontalLine = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAACCAMAAABv2Ay5AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAAZQTFRFm5ubAAAAHlEv6wAAAA5JREFUeNpiYCAWAAQYAAAqAAGYjNEzAAAAAElFTkSuQmCC" // Encoded image for displaying in "News" webView
var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())