////
////  LocalCoreDataModel.swift
////  Pontilho
////
////  Created by Isabela Hissa Pinto on 21/07/25.
////
//
//import Foundation
//import CoreData
//
//class LocalCoreDataModel: ObservableObject {
//    
//    public static let shared = LocalCoreDataModel()
//    
//    private let persistentContainer: NSPersistentContainer
//    public var viewContext: NSManagedObjectContext {
//        persistentContainer.viewContext
//    }
//    
//    private init() {
//        persistentContainer = NSPersistentContainer(name: "LocalModel")
//        persistentContainer.loadPersistentStores(completionHandler: { _, error in
//            if let error = error {
//                fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription))")
//            }
//        })
//    }
//    
//    func saveContext() {
//        if viewContext.hasChanges {
//            do {
//                try viewContext.save()
//            } catch {
//                print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
//            }
//        }
//    }
//    
//    func createLocais(title: String, desc: String, isDone: Bool) -> ToDo {
//        let toDo = ToDo(context: viewContext)
//        
//        toDo.title = title
//        toDo.desc = desc
//        toDo.isDone = isDone
//        
//        saveContext()
//        return toDo
//    }
//    
//    func fetchLocais() -> [Local] {
//        let fetchRequest: NSFetchRequest<Local> = Local.fetchRequest()
//        
//        do {
//            let result = try viewContext.fetch(fetchRequest)
//            return result
//        } catch {
//            print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
//            return []
//        }
//    }
//    
//    public func createLocais(
//}
