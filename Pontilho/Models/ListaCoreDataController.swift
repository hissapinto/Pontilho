//
//  ListaCoreDataController.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 23/07/25.
//

//
//  LocalCoreDataModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 21/07/25.
//

import Foundation
import CoreData

class ListaCoreDataController: ObservableObject {
    
    public static let shared = ListaCoreDataController()
    
    private let persistentContainer: NSPersistentContainer
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
//    static var preview: ListaCoreDataController = {
//        let controller = ListaCoreDataController(inMemory: true)
//        let viewcontext = controller.container?.viewContext
//        do{
//            let listaExemplo = Lista(context: controller.container?.viewContext)
//            listaExemplo.name = "Cafés"
//            listaExemplo.color = "azulzinho"
//            listaExemplo.id = UUID()
//            listaExemplo.image = "CoffeeShop"
//        } catch {
//            fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription))")
//        }
//        return controller
//    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription)")
            }
        }
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
    
    func createLista(id: UUID, name: String, color: String, image: String) -> Lista {
        let lista = Lista(context: viewContext)
        
        lista.id = UUID()
        lista.name = name
        lista.color = color
        lista.image = image
        lista.locais = []
        
        saveContext()
        return lista
    }
    
    func fetchListas() -> [Lista] {
        let fetchRequest: NSFetchRequest<Lista> = Lista.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
            return []
        }
    }
    
    func deleteLista(_ lista: Lista) {
        viewContext.delete(lista)
        saveContext()
    }

}


