//
//  LocalCDViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 23/07/25.
//

import Foundation
import CoreData
import MapKit

class CDViewModel: ObservableObject {
    @Published var locais: [Local] = []
    
    func getLocal() {
        locais = CoreDataController.shared.fetchLocais()
    }
    
    func createLocal(name: String, latitude: Double, longitude: Double, type: String) {
        let result = CoreDataController.shared.createLocais(id: UUID(), name: name, latitude: latitude, longitude: longitude, type: type)
        self.locais.append(result)
    }
    
    func deleteLocal(_ local: Local) {
        CoreDataController.shared.deleteLocal(local)
    }
    
    func saveLocal(_ local: Local) {
        CoreDataController.shared.saveContext()
        getLocal()
    }
}
