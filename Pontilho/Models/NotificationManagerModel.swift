//
//  NotificationManagerModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 29/07/25.
//

import Foundation
import SwiftUI
import MapKit

/// A model that abstracts a manager to send and schedule notifications.
struct NotificationManagerModel {
    public static var shared: NotificationManagerModel = {
        let instance = NotificationManagerModel()
        
        return instance
    }()
    
    private init() {}
    
    private static var coreDataViewModel: CDViewModel = CDViewModel()

    
    /// Request all the necessary permissions to ensure that local notifications will work.
    public static func requirePermissions() {
        // Ask permission to send alerts, use badges and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { status, error in
            if !status, let error = error {
                fatalError("[ERROR]: Unable to request permissions for notifications (\(error.localizedDescription))")
            }
        }
    }
    
    public static func scheduleGeolocalizedNotification(notification: NotificationModel, latitude: Double, longitude: Double) {
        // Notification content creation
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.sound = UNNotificationSound.default
        
        //Define location
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //Define circular region
        let region = CLCircularRegion(center: center, radius: 100, identifier: "Quarteirão")
        
        //Engage only on Entry
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        //create trigger
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        // Notification send request
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    /// Cancel a scheduled notification, canceling it from the notification center and removing it from core data.
    /// - Parameters:
    ///     - scheduledNotification: A ScheduledNotification to be canceled and removed.
    public static func cancelScheduledNotification(scheduledNotification: ScheduledNotification) {
        // Cancel the notification using its id
        if let id = scheduledNotification.id?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
        
        // Delete the scheduled notification from core data
        coreDataViewModel.deleteScheduledNotification(scheduledNotification: scheduledNotification)
    }
}
