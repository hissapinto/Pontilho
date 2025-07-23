//
//  LocalCDViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 23/07/25.
//

import Foundation
import CoreData
import MapKit

class LocalCDViewModel: ObservableObject {
    @Published var locais: [Local] = []
    
    func getLocal() {
        locais = LocalCoreDataController.shared.fetchLocais()
    }
    
    func createLocal(id: UUID, name: String, latitude: Double, longitude: Double, lista: Lista) {
        let result = LocalCoreDataController.shared.createLocais(id: id, name: name, latitude: latitude, longitude: longitude, lista: lista)
        self.locais.append(result)
    }
    
    func deleteLocal(_ local: Local) {
        LocalCoreDataController.shared.deleteLocal(local)
    }
    
    func saveLocal(_ local: Local) {
        LocalCoreDataController.shared.saveContext()
        getLocal()
    }
}
