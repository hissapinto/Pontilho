//
//  LocalCoreDataModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 21/07/25.
//

import Foundation
import CoreData

class LocalCoreDataModel {
    public static let shared = LocalCoreDataModel()
    
    private let persistentContainer: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "LocalModel")
        persistentContainer.loadPersistentStores(completionHandler: { _,
            error in
            if let error = error {
                fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription))")
            }
        })
    }
    
    public func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
            }
        }
    }
    
    public func fetchScheduledNotifications() -> [Local] {
        let fetchRequest: NSFetchRequest<Local> =
        Local.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
            return []
        }
    }
}
