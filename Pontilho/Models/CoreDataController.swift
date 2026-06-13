//
//  LocalCoreDataModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 21/07/25.
//

import Foundation
import CoreData
import MapKit

@Observable
class CoreDataController {
    
    public static let shared = CoreDataController()
    
    private let persistentContainer: NSPersistentContainer
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription))")
            }
            self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            //pra decidir como salvar um lugar duplicado
        })
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
            }
        }
    }
    
    func createLocais(name: String, latitude: Double, longitude: Double, type: String, identifier: String) -> Local {
        let local = Local(context: viewContext)
        
        local.id = UUID()
        local.name = name
        local.latitude = latitude
        local.longitude = longitude
        local.type = type
        local.identifier = identifier
        
        saveContext()
        return local
    }
    
    func fetchLocais() -> [Local] {
        let fetchRequest: NSFetchRequest<Local> = Local.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
            return []
        }
    }
    
    func deleteLocal(_ local: Local) {
        viewContext.delete(local)
        saveContext()
    }
    
    public func fetchScheduledNotifications() -> [ScheduledNotification] {
        let fetchRequest: NSFetchRequest<ScheduledNotification> = ScheduledNotification.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        }
        catch {
            print("[WARNING]: Failed to fetch scheduled notifications (\(error.localizedDescription))")
            return []
        }
    }
    
    public func createScheduledNotification(id: UUID, date: Date) -> ScheduledNotification {
        let scheduledNotification: ScheduledNotification = ScheduledNotification(context: viewContext)
        scheduledNotification.id = id
        scheduledNotification.date = date
        saveContext()
        
        return scheduledNotification
    }
    
    public func deleteNotification(scheduledNotification: ScheduledNotification) {
        viewContext.delete(scheduledNotification)
        saveContext()
    }
}
