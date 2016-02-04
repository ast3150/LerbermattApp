//
//  GLBusAPI.swift
//  Gymkl Swift
//
//  Created by Alain Stulz on 27/12/15.
//  Copyright © 2015 Alain Stulz. All rights reserved.
//

import UIKit
import SwiftyJSON

class GLBusAPI: NSObject, SwiftyTransportDelegate {
    static var sharedInstance = GLBusAPI()
    var networkHandler: SwiftyTransport
    
    override init() {
        self.networkHandler = SwiftyTransport()
        super.init()
        self.networkHandler.delegate = self
    }
    
    /*
    getStationList()
    getDeparturesForStation()
    updateDepartures()
    addStation()
    */
    
    // MARK: Locations
    func getLocationsForQuery(query: String, withType type: LocationType = .All) {
        networkHandler.getLocationsForQuery(query, type: type)
    }
    
    func didGetLocationsData(data: NSData) {
        let json = JSON(data: data)
        
        NSNotificationCenter.defaultCenter().postNotificationName("GLDidGetLocationsData", object: self, userInfo: json.dictionaryObject)
    }
    
    // MARK: Departures
    func getDeparturesForLocation(location: Location) {
        // update from network
        // return stored
        // notify view when updated
    }
    
    
    func didGetConnectionsData(data: NSData) {
        let json = JSON(data: data)
        print(json)
    }
    
    // MARK: Stationboard
    
    func didGetStationboardData(data: NSData) {
        
    }
    
    // MARK: Error handling
    
    func didFailWithError(error: NSError?) {
        
    }

}

extension GLBusAPI {
    
}
