//
//  TabBarView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftUI

/// An enum representing each tab in the app.
enum Tab {
    case journal
    case alarm
    case interpret
    case profile
}

/// A reusable floating tab bar for switching between the four primary tabs.
struct TabBarView: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            TabBarItem(
                icon: "book.fill",
                title: "Journal",
                isSelected: selectedTab == .journal
            )
            .onTapGesture {
                selectedTab = .journal
            }

            TabBarItem(
                icon: "alarm.fill",
                title: "Alarm",
                isSelected: selectedTab == .alarm
            )
            .onTapGesture {
                selectedTab = .alarm
            }

            TabBarItem(
                icon: "sparkles",
                title: "Interpret",
                isSelected: selectedTab == .interpret
            )
            .onTapGesture {
                selectedTab = .interpret
            }

            TabBarItem(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == .profile
            )
            .onTapGesture {
                selectedTab = .profile
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

/// A view representing a single tab item with an icon and title.
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))

            Text(title)
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .blue : .gray)
        .frame(maxWidth: .infinity)
    }
}
