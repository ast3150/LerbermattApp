//
//  SwiftyTransport.swift
//
//  Created by Alain Stulz on 28/12/15.
//  Copyright © 2015 Alain Stulz. All rights reserved.
//

import UIKit

let baseURL = "http://transport.opendata.ch/v1/"

class SwiftyTransport: NSObject {
    var delegate: SwiftyTransportDelegate!
    
    // MARK: Locations
    
    /**
    Returns the matching locations for the given parameters. Either query or ( x and y ) are required.
    
    The locations in the response are scored to determine which is the most exact location.
    
    This method can return a refine response, what means that the request has to be redone.
    
     - parameter query: A search query, e.g. "Bern, Bahnhof"
     - parameter coordinates: A Location to list the nearest locations
     - parameter type: Only with query, type of the location, see LocationType
     - parameter transportations: Only with coordinates, type of transportations leaving from location, see Transportations
    */
    func getLocations(query: String?, coordinates:(x: Float, y: Float)?, type: LocationType?, transportations: [Transportations]?){
        
        let resource = "locations"
        var parameters = [String]()
        
        // Parameters
        if let query = query {
            parameters.append("query=\(query)")
            if let type = type {
                parameters.append("type=\(type.rawValue)")
            }
        }
        
        if let coordinates = coordinates {
            parameters.append("x=\(coordinates.x)")
            parameters.append("y=\(coordinates.y)")
            if let transportations = transportations {
                for transportation in transportations {
                    parameters.append("transportations[]=\(transportation.rawValue.lowercaseString)")
                }
            }
        }
        
        var urlString = baseURL + resource
        
        for parameter in parameters {
            if urlString == baseURL + resource {
                // First parameter
                urlString += "?\(parameter)"
            } else {
                urlString += "&\(parameter)"
            }
        }
        
        // Request
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()

        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                self.delegate.didFailWithError(nil)
                return
            }
            
            guard error == nil else {
                self.delegate.didFailWithError(error)
                return
            }
            
            guard data != nil else {
                self.delegate.didFailWithError(nil)
                return
            }

            self.delegate.didGetLocationsData(data!)
        }.resume()
    }

    /**
     getLocations by Query
     
     - parameter query: A search query, e.g. "Bern, Bahnhof"
     - parameter type: Type of the location, see LocationType
     */
    func getLocationsForQuery(query: String, type: LocationType?) {
        getLocations(query, coordinates: nil, type: nil, transportations: nil)
    }
    
    /**
     getLocations by Coordinates

     - parameter coordinates: A Location to list the nearest locations
     - parameter transportations: Type of transportations leaving from location, see Transportations
     */
    func getLocationsByCoordinates(coordinates: (x: Float, y: Float), transportations: [Transportations]?) {
        getLocations(nil, coordinates: coordinates, type: nil, transportations: transportations)
    }

    
    // MARK: Connections
    
    /**
    Returns the next connections from a location to another.
    
    - parameter from: Specifies the departure location of the connection
    - parameter to: Specifies the arrival location of the connection	
    - parameter via: Specifies up to five via locations.
    - parameter date: Date of the connection, in the format YYYY-MM-DD
    - parameter time: Time of the connection, in the format hh:mm
    - parameter isArrivalTime: If set to true the passed date and time is the arrival time
    - parameter transportations: Type of transportations leaving from location, see Transportations
    - parameter limit: 1 - 6. Specifies the number of connections to return. If several connections depart at the same time they are counted as 1.
    - parameter page: 0 - 10. Allows pagination of connections. Zero-based, so first page is 0, second is 1, third is 2 and so on.
    - parameter direct: Defaults to false, if set to true only direct connections are allowed
    - parameter sleeper: Defaults to false, if set to true only night trains containing beds are allowed, implies direct=1
    - parameter couchette: Defaults to false, if set to true only night trains containing couchettes are allowed, implies direct=1
    - parameter bike: Defaults to false, if set to true only trains allowing the transport of bicycles are allowed
    - parameter accessibility: Sets the level of accessibility required, see AccessibilityType
    */
    func getConnections(from: String, to: String, vias: [String]?, date: String?, time: String?, isArrivalTime: Bool?, transportations: [Transportations]?, limit: Int?, page: Int?, direct: Bool?, sleeper: Bool?, couchette: Bool?, bike: Bool?, accessibility: AccessibilityType?) throws {
        
        let resource = "connections"
        var parameters = [String]()
        
        // Parameters
        parameters.append("from=\(from)")
        parameters.append("to=\(to)")
        if let vias = vias {
            if vias.count == 1 {
                parameters.append("via=\(vias.first!)")
            } else {
                for via in vias {
                    parameters.append("via[]=\(via)")
                }
            }
            
        }
        if let date = date {
            parameters.append("date=\(date)")
        }
        if let time = time {
            parameters.append("time=\(time)")
        }
        if let isArrivalTime = isArrivalTime {
            parameters.append("isArrivalTime=\(isArrivalTime ? 1 : 0)")
        }
        if let transportations = transportations {
            for transportation in transportations {
                parameters.append("transportations[]=\(transportation.rawValue.lowercaseString)")
            }
        }
        if let limit = limit {
            parameters.append("limit=\(limit)")
        }
        if let page = page {
            parameters.append("page=\(page)")
        }
        if let direct = direct {
            parameters.append("direct=\(direct ? 1 : 0)")
        }
        if let sleeper = sleeper {
            parameters.append("sleeper=\(sleeper ? 1 : 0)")
        }
        if let couchette = couchette {
            parameters.append("couchette=\(couchette ? 1 : 0)")
        }
        if let bike = bike {
            parameters.append("bike=\(bike ? 1 : 0)")
        }
        if let accessibility = accessibility {
            parameters.append("accessibility=\(accessibility.rawValue)")
        }
        
        var urlString = baseURL + resource
        
        for parameter in parameters {
            if urlString == baseURL + resource {
                // First parameter
                urlString += "?\(parameter)"
            } else {
                urlString += "&\(parameter)"
            }
        }
        
        // Request
        if let urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            let session = NSURLSession.sharedSession()
            
            session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                    self.delegate.didFailWithError(nil)
                    return
                }
                
                guard error == nil else {
                    self.delegate.didFailWithError(error)
                    return
                }
                
                guard data != nil else {
                    self.delegate.didFailWithError(nil)
                    return
                }
                
                self.delegate.didGetConnectionsData(data!)
            }.resume()
        } else {
            throw SwiftyTransportError.InvalidURL
        }
    }
    
    /**
     getConnections by Locations
     
     - parameter from: Specifies the departure location of the connection
     - parameter to: Specifies the arrival location of the connection
     */
    func getConnectionsByLocations(from: String, to: String) throws {
        try getConnections(from, to: to, vias: nil, date: nil, time: nil, isArrivalTime: nil, transportations: nil, limit: nil, page: nil, direct: nil, sleeper: nil, couchette: nil, bike: nil, accessibility: nil)
    }
    
    // MARK: Stationboard
    
    /**
    Returns the next connections leaving from a specific location.
    
    - parameter station: Specifies the location of which a stationboard should be returned	
    - parameter id: The id of the station whose stationboard should be returned. Alternative to the station parameter; one of these two is required. If both an id and a station are specified the id has precedence.
    - parameter limit: Number of departing connections to return. This is not a hard limit - if multiple connections leave at the same time it'll return any connections that leave at the same time as the last connection within the limit.
    - parameter transportations: Type of transportations leaving from location, see Transportations
    - parameter datetime: Date and time of departing connections, in the format YYYY-MM-DD hh:mm.
    */
    func getStationboard(station: String?, id: String?, limit: Int?, transportations: [Transportations]?, datetime: String?) throws {
        guard (station != nil) || (id != nil) else {
            throw SwiftyTransportError.InvalidParameters
        }
        
        let resource = "stationboard"
        var parameters = [String]()
        
        // Parameters
        
        if let station = station {
            parameters.append("station=\(station)")
        }
        if let id = id {
            parameters.append("id=\(id)")
        }
        if let limit = limit {
            parameters.append("limit=\(limit)")
        }
        if let transportations = transportations {
            for transportation in transportations {
                parameters.append("transportations[]=\(transportation.rawValue.lowercaseString)")
            }
        }
        if let datetime = datetime {
            parameters.append("datetime=\(datetime)")
        }
        
        var urlString = baseURL + resource
        
        for parameter in parameters {
            if urlString == baseURL + resource {
                // First parameter
                urlString += "?\(parameter)"
            } else {
                urlString += "&\(parameter)"
            }
        }
        
        // Request
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 else {
                self.delegate.didFailWithError(nil)
                return
            }
            
            guard error == nil else {
                self.delegate.didFailWithError(error)
                return
            }
            
            guard data != nil else {
                self.delegate.didFailWithError(nil)
                return
            }
            
            self.delegate.didGetStationboardData(data!)
        }.resume()
    }
    
    /**
     getStationboard for Station Name
     
     - parameter station: Specifies the location of which a stationboard should be returned
     */
    func getStationboardForStation(station: String) throws {
        try getStationboard(station, id: nil, limit: nil, transportations: nil, datetime: nil)
    }
    
    /**
     getStationboard for Station id
     
     - parameter id: The id of the station whose stationboard should be returned. Alternative to the station parameter
     */
    func getStationboardForID(id: String) throws {
        try getStationboard(nil, id: id, limit: nil, transportations: nil, datetime: nil)
    }
}

enum LocationType: String {
    case All
    case Station
    case POI
    case Address
}

enum Transportations: String {
    case ICE_TGV_RJ
    case EC_IC
    case IR
    case RE_D
    case Ship
    case S_SN_R
    case Bus
    case Cableway
    case ARZ_EXT
    case Tramway_Underground
}

enum AccessibilityType: String {
    case Independent_Boarding
    case Assisted_Boarding
    case Advanced_Notice
}

enum SwiftyTransportError: ErrorType {
    case InvalidParameters
    case InvalidURL
}

protocol SwiftyTransportDelegate {
    func didGetLocationsData(data: NSData)
    func didGetConnectionsData(data: NSData)
    func didGetStationboardData(data: NSData)
    func didFailWithError(error: NSError?)
}