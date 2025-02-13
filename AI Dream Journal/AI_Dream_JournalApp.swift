//
//  AI_Dream_JournalApp.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

@main
struct AI_Dream_JournalApp: App {
    init() {
        requestNotificationPermissions()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Alarm.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
            print("Notifications granted: \(granted)")
        }
    }
}
