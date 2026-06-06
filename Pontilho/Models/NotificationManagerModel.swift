//
//  NotificationManagerModel.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 29/07/25.
//

import Foundation
import SwiftUI

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

    /// Schedule a local notification to be sent at a specific time (hour:minute), with the option to repeat it every day at this time.
    /// - Parameters:
    ///     - notification: A notification model representing the local notification.
    ///     - hour: The hour to send the notification.
    ///     - minute: The minute to send the notification.
    ///     - repeating: If true, repeat this notification every day at the same time (hour:minute), if not, send only once. The default is false.
    public static func scheduleNotification(notification: NotificationModel, days: Int, repeating: Bool = false) {
        // Notification content creation
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.sound = UNNotificationSound.default

        // Notification calendar trigger with date components
        var dateComponents = DateComponents()
        dateComponents.day = 7
        //dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)

        // Notification send request
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        // Create a scheduled notification entry using core data to retrieve it later
        if repeating {
            let date: Date = Calendar.current.date(from: dateComponents) ?? .now
            coreDataViewModel.createScheduledNotification(id: notification.id, date: date)
        }
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
