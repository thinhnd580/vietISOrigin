//
//  Point+CoreDataProperties.swift
//  iBus
//
//  Created by Thinh on 4/11/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Point {

    @NSManaged var id: NSNumber?
    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var name: String?
    @NSManaged var routes: NSSet?
    func addRouteObject(value:Route) {
        let items = self.mutableSetValueForKey("routes");
        items.addObject(value)
    }
    func removeRouteObject(value:Route) {
        let items = self.mutableSetValueForKey("routes");
        items.removeObject(value)
    }
}
