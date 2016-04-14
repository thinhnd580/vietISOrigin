//
//  Route+CoreDataProperties.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/14/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Route {

    @NSManaged var busNumber: String?
    @NSManaged var routeTrip: String?
    @NSManaged var tripDetail: String?
    @NSManaged var polyline: String?
    @NSManaged var goPoints: NSOrderedSet?
    @NSManaged var returnPoints: NSOrderedSet?
    func addGoPointObject(value:Point) {
        let items = self.mutableOrderedSetValueForKey("goPoints");
        
        //        let items = self.valueForKey("goPoints")
        items.addObject(value)
    }
    
    func removePointObject(value:Point) {
        let items = self.mutableSetValueForKey("goPoints");
        items.removeObject(value)
    }
}
