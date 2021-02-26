//
//  UrlExtension.swift
//  EventsApp
//
//  Created by alex on 27.02.2021.
//  Copyright © 2021 washinson. All rights reserved.
//

import Foundation
import CoreData

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

func saveContext(container: NSPersistentContainer) {
    if container.viewContext.hasChanges {
        do {
            try container.viewContext.save()
        } catch {
            print("An error occurred while saving: \(error)")
        }
    }
}
