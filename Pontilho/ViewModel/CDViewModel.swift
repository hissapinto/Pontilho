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

@Observable
class CDViewModel {
    var locais: [Local] = []
    public var scheduledNotifications: [ScheduledNotification] = []
    
    func getLocal() {
        locais = CoreDataController.shared.fetchLocais()
    }
    
    func createLocal(name: String, latitude: Double, longitude: Double, type: String, identifier: String) -> Local {
        let result = CoreDataController.shared.createLocais(id: UUID(), name: name, latitude: latitude, longitude: longitude, type: type, identifier: identifier)
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
    
    public func createScheduledNotification(id: UUID, date: Date) {
        let newScheduledNotification: ScheduledNotification = CoreDataController.shared.createScheduledNotification(id: id, date: date)
        self.scheduledNotifications.append(newScheduledNotification)
    }
    
    public func deleteScheduledNotification(scheduledNotification: ScheduledNotification) {
        CoreDataController.shared.deleteNotification(scheduledNotification: scheduledNotification)
    }
}
