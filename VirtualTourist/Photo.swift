//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 6/9/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    // MARK: - Init model
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photoURL: String, title: String,photoId: String, pin: Pin, context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.url = photoURL
        self.title = title
        self.id = photoId
        self.pin = pin
        
        print("init from Photos.swift\(url)")
        
    }
}
