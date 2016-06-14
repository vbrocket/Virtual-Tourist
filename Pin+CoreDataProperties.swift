//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 5/30/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var pageCount: NSNumber?
    @NSManaged var photos: NSSet?

}
