//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ibrahim.Moustafa on 6/9/16.
//  Copyright © 2016 Ibrahim.Moustafa. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var id: String?
    @NSManaged var imageData: NSData?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var pin: Pin?

}
