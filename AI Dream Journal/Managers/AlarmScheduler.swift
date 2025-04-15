//
//  AlarmScheduler.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import UserNotifications
import SwiftData

struct AlarmScheduler {
    static func scheduleAlarm(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = alarm.label
        content.body = "Tap here to record a new dream entry!"
        content.sound = UNNotificationSound.default
        
        // Add a category identifier that will be used to show custom actions
        content.categoryIdentifier = "DREAM_ALARM"
        
        // Convert alarm time (Date) to hours/minutes
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: alarm.time)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true // Repeat every day at the same time
        )

        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling alarm: \(error.localizedDescription)")
            }
        }
    }

    static func cancelAlarm(_ alarm: Alarm) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }
    
    static func setupNotificationCategories() {
        // Create actions
        let recordAction = UNNotificationAction(
            identifier: "RECORD_DREAM",
            title: "Record Dream",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: .destructive
        )
        
        // Create category
        let dreamCategory = UNNotificationCategory(
            identifier: "DREAM_ALARM",
            actions: [recordAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([dreamCategory])
    }
}
