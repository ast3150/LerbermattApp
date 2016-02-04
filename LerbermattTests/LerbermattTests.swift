//
//  LerbermattTests.swift
//  LerbermattTests
//
//  Created by Alain Stulz on 28/12/15.
//  Copyright © 2015 Alain Stulz. All rights reserved.
//

import XCTest
import SwiftyJSON

class LerbermattTests: XCTestCase {
    var responseExpectation = XCTestExpectation()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
        
    func testGetConnections() {
        let busNetworking = SwiftyTransport()
        busNetworking.delegate = self
        responseExpectation = self.expectationWithDescription("network responded")
        
        try! busNetworking.getConnections("Bern", to: "Zürich", vias: ["Olten", "Aarau"], date: "2016-12-30", time: "23:22", isArrivalTime: true, transportations: [Transportations.EC_IC], limit: 1, page: nil, direct: true, sleeper: false, couchette: false, bike: true, accessibility: nil)
        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssert(true)
    }
    
    func testGetLocations() {
        let busNetworking = SwiftyTransport()
        busNetworking.delegate = self
        responseExpectation = self.expectationWithDescription("network responded")
        
        // Expected:
        // Bern, x: 46.948825, y: 7.439122, id: 008507000
        busNetworking.getLocations("Ler", coordinates: nil, type: nil, transportations: nil)
        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssert(true)
    }
    
    func testGetStationboard() {
        let busNetworking = SwiftyTransport()
        busNetworking.delegate = self
        responseExpectation = self.expectationWithDescription("network responded")
        
        try! busNetworking.getStationboard("Lerbermatt", id: nil, limit: 1, transportations: nil, datetime: nil)
        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssert(true)
    }
    
}

extension LerbermattTests: SwiftyTransportDelegate {
    func didGetConnectionsData(data: NSData) {
        if JSON(data: data) != nil {
            print(JSON(data: data))
            responseExpectation.fulfill()
        }
    }
    func didGetLocationsData(data: NSData) {
        if JSON(data: data) != nil {
            print(JSON(data: data))
            responseExpectation.fulfill()
        }    }
    func didGetStationboardData(data: NSData) {
        if JSON(data: data) != nil {
            print(JSON(data: data))
            responseExpectation.fulfill()
        }
    }
    func didFailWithError(error: NSError?) {
        print("ERROR \(error?.localizedDescription)")
    }
}