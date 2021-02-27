//
//  Event+CoreDataProperties.swift
//  EventsApp
//
//  Created by alex on 26.02.2021.
//  Copyright © 2021 washinson. All rights reserved.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var date: Date
    @NSManaged public var note: String
    @NSManaged public var status: String
    @NSManaged public var title: String

}
