//
//  ContentView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Tab = .journal
    @Binding var showJournalEntryOnLaunch: Bool
    @State private var showDreamEntry = false
    
    init(showJournalEntryOnLaunch: Binding<Bool> = .constant(false)) {
        self._showJournalEntryOnLaunch = showJournalEntryOnLaunch
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .journal:
                JournalView(showDreamEntry: $showDreamEntry)
            case .alarm:
                AlarmView()
            case .interpret:
                InterpretView()
            case .profile:
                ProfileView()
            }

            // Floating Tab Bar
            TabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: .dreamAlarmFired)) { _ in
            selectedTab = .journal
            showDreamEntry = true
        }
        .onAppear {
            if showJournalEntryOnLaunch {
                selectedTab = .journal
                showDreamEntry = true
                showJournalEntryOnLaunch = false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Dream.self, Alarm.self], inMemory: true)
}
