//
//  LocalCDViewModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 23/07/25.
//

import Foundation
import CoreData
import MapKit
import SwiftUI

class CDViewModel: ObservableObject {
    @Published var locais: [Local] = []
    @Published public var scheduledNotifications: [ScheduledNotification] = []
    
    func getLocal() {
        locais = CoreDataController.shared.fetchLocais()
    }
    
    func createLocal(name: String, latitude: Double, longitude: Double, type: String) -> Local {
        let result = CoreDataController.shared.createLocais(id: UUID(), name: name, latitude: latitude, longitude: longitude, type: type)
        self.locais.append(result)
        return result
    }
    
    func deleteLocal(_ local: Local) {
        CoreDataController.shared.deleteLocal(local)
    }
    
    func saveLocal(_ local: Local) {
        CoreDataController.shared.saveContext()
        getLocal()
    }
    
    public func getNotifications() {
        scheduledNotifications = CoreDataController.shared.fetchScheduledNotifications()
    }
    
    public func createScheduledNotification(id: UUID, latitude: Double, longitude: Double) {
        let newScheduledNotification: ScheduledNotification = CoreDataController.shared.createScheduledNotification(id: id, latitude: latitude, longitude: longitude)
        self.scheduledNotifications.append(newScheduledNotification)
    }
    
    public func deleteScheduledNotification(scheduledNotification: ScheduledNotification) {
        CoreDataController.shared.deleteNotification(scheduledNotification: scheduledNotification)
    }
}
