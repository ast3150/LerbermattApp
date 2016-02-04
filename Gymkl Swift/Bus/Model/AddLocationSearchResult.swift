//
//  AddLocationSearchResult.swift
//  Lerbermatt
//
//  Created by Alain Stulz on 31.01.16.
//  Copyright © 2016 Alain Stulz. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddLocationSearchResult: NSObject {
    var id: Int!
    var name: String!
    var score: Int?
    var x: Double?
    var y: Double?
    
    init?(json: JSON) {
        super.init()
        
        guard let name = json["name"].string, let id = json["id"].string else {
            return nil
        }
        
        self.name = name
        self.id = Int(id)
        self.score = json["score"].int
        self.x = json["coordinate"]["x"].double
        self.y = json["coordinate"]["y"].double
    }
}