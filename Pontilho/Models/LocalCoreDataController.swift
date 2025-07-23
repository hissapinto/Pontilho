//
//  LocalCoreDataModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 21/07/25.
//

import Foundation
import CoreData
import MapKit

class LocalCoreDataController: ObservableObject {
    
    public static let shared = LocalCoreDataController()
    
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
    
    func createLocais(id: UUID, name: String, latitude: Double, longitude: Double, lista: Lista) -> Local {
        let local = Local(context: viewContext)
        
        local.id = UUID()
        local.name = name
        local.latitude = latitude
        local.longitude = longitude
        lista.addToLocais(local)
        
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
    
}
