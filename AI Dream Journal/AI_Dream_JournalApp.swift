//
//  AI_Dream_JournalApp.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

// Custom AppStorage key for theme preferences
enum AppStorageKeys {
    static let darkModeEnabled = "darkModeEnabled"
}

// App theme settings
class ThemeSettings: ObservableObject {
    @AppStorage(AppStorageKeys.darkModeEnabled) var darkModeEnabled = false
}

@main
struct AI_Dream_JournalApp: App {
    @State private var showJournalEntryOnLaunch = false
    @StateObject private var themeSettings = ThemeSettings()
    
    init() {
        setupNotifications()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Dream.self,
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
            ContentView(showJournalEntryOnLaunch: $showJournalEntryOnLaunch)
                .onAppear {
                    handleLaunchFromNotification()
                }
                .preferredColorScheme(themeSettings.darkModeEnabled ? .dark : .light)
                .environmentObject(themeSettings)
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupNotifications() {
        requestNotificationPermissions()
        AlarmScheduler.setupNotificationCategories()
        
        // Set up delegate to handle notification actions
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
            print("Notifications granted: \(granted)")
        }
    }
    
    private func handleLaunchFromNotification() {
        // Check if the app was launched from a notification
        if let launchOptions = ProcessInfo.processInfo.environment["UIApplicationLaunchOptionsRemoteNotificationKey"] {
            showJournalEntryOnLaunch = true
        }
    }
}

// Create a notification delegate to handle notification actions
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // This is called when a notification is received while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Allow notifications to be shown in foreground
        completionHandler([.banner, .sound])
    }
    
    // This is called when the user interacts with a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "RECORD_DREAM":
            // Handle the record dream action
            NotificationCenter.default.post(name: .dreamAlarmFired, object: nil)
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            NotificationCenter.default.post(name: .dreamAlarmFired, object: nil)
            
        default:
            break
        }
        
        completionHandler()
    }
}
