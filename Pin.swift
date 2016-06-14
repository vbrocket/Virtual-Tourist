//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 5/30/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
    
    // In Swift, superclass initializers are not available to subclasses, so it is necessary to include this initializer and call the superclass' implementation of it.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat: Double, long: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = lat
        self.longitude = long
        self.pageCount = 0
    }
}
