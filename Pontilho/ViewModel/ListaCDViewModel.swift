//
//  ListaCDViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 23/07/25.
//

import Foundation
import CoreData

class ListaCDViewModel: ObservableObject {
    @Published var listas: [Lista] = []
    
    func getLista() {
        listas = ListaCoreDataController.shared.fetchListas()
    }
    
    func createLista(id: UUID, name: String, color: String, image: String) {
        let result = ListaCoreDataController.shared.createLista(id: id, name: name, color: color, image: image)
        self.listas.append(result)
    }
    
    func deleteLista(_ lista: Lista) {
        ListaCoreDataController.shared.deleteLista(lista)
    }
    
    func saveLista(_ lista: Lista) {
        ListaCoreDataController.shared.saveContext()
        getLista()
    }
}
