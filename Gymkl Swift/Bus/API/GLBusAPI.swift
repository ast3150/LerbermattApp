//
//  GLBusAPI.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 27/12/15.
//  Copyright © 2015 Alain Stulz. All rights reserved.
//

import UIKit

class GLBusAPI: NSObject {
    static var sharedInstance = GLBusAPI()
    
    /*
    getStationList()
    getDeparturesForStation()
    updateDepartures()
    addStation()
    */
    
    func getDeparturesForLocation(station: Location) {
        // update from network
        // return stored
        // notify view when updated
    }
}
