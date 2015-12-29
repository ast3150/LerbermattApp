//
//  Departure+CoreDataProperties.swift
//  
//
//  Created by Alain Stulz on 28/12/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Departure {

    @NSManaged var absoluteTime: NSDate?
    @NSManaged var destination: String?
    @NSManaged var relativeTime: String?
    @NSManaged var location: NSManagedObject?

}
