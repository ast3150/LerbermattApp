//
//  Location+CoreDataProperties.swift
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

extension Location {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var departures: NSSet?

}
