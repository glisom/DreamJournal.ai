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
    @Query private var items: [Item]
    @State private var selectedTab: Tab = .journal

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selectedTab {
            case .journal:
                JournalView()
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Alarm.self, inMemory: true)
}
