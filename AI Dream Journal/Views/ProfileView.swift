//
//  ProfileView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dreams: [Dream]
    @Query private var alarms: [Alarm]
    
    @State private var showPaywall = false
    @State private var isPremiumUser = false // This would be stored in UserDefaults or a more secure method in a real app
    
    var body: some View {
        NavigationView {
            List {
                // User profile section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Dream Explorer")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if isPremiumUser {
                                Label("Premium Member", systemImage: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            } else {
                                Button {
                                    showPaywall = true
                                } label: {
                                    Label("Upgrade to Premium", systemImage: "star")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Dream stats section
                Section(header: Text("Your Dream Journey")) {
                    statsRow(title: "Dreams Recorded", value: "\(dreams.count)")
                    statsRow(title: "Dreams Interpreted", value: "\(dreams.filter { $0.isInterpreted }.count)")
                    statsRow(title: "Active Alarms", value: "\(alarms.filter { $0.isEnabled }.count)")
                    
                    NavigationLink(destination: DreamTagsView(dreams: dreams)) {
                        statsRow(title: "Unique Tags", value: "\(uniqueTags().count)")
                    }
                }
                
                // Settings section
                Section(header: Text("Settings")) {
                    Toggle("Dark Mode", isOn: .constant(false)) // This would use AppStorage in a real app
                    Toggle("Notifications", isOn: .constant(true))
                    
                    if !isPremiumUser {
                        settingsRow(icon: "lock.fill", title: "Sleep Quality Tracking", isPremium: true)
                        settingsRow(icon: "lock.fill", title: "Dream Pattern Analysis", isPremium: true)
                    } else {
                        NavigationLink(destination: Text("Health Integration View")) {
                            settingsRow(icon: "heart.fill", title: "HealthKit Integration", isPremium: false)
                        }
                        
                        NavigationLink(destination: Text("Analytics View")) {
                            settingsRow(icon: "chart.bar.fill", title: "Dream Analytics", isPremium: false)
                        }
                    }
                }
                
                // About section
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("Privacy Policy Content")) {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink(destination: Text("Terms of Service Content")) {
                        Text("Terms of Service")
                    }
                    
                    NavigationLink(destination: Text("Help & Support Content")) {
                        Text("Help & Support")
                    }
                    
                    if isPremiumUser {
                        Button {
                            // In a real app this would restore purchases
                        } label: {
                            Text("Restore Purchases")
                        }
                    }
                    
                    Text("Version 1.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .safeAreaInset(edge: .bottom) {
                // Add spacing for the floating tab bar
                Spacer().frame(height: 70)
            }
        }
    }
    
    private func statsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
    
    private func settingsRow(icon: String, title: String, isPremium: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isPremium ? .gray : .blue)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(isPremium ? .gray : .primary)
            
            if isPremium {
                Spacer()
                
                Button {
                    showPaywall = true
                } label: {
                    Text("Premium")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(5)
                }
            }
        }
    }
    
    private func uniqueTags() -> Set<String> {
        var tags = Set<String>()
        for dream in dreams {
            for tag in dream.tags {
                tags.insert(tag)
            }
        }
        return tags
    }
}

struct DreamTagsView: View {
    let dreams: [Dream]
    
    var body: some View {
        let tags = getTags()
        
        return List {
            ForEach(Array(tags.keys.sorted()), id: \.self) { tag in
                NavigationLink(destination: 
                    DreamsByTagView(tag: tag, dreams: dreams.filter { $0.tags.contains(tag) })
                ) {
                    HStack {
                        Text(tag)
                        Spacer()
                        Text("\(tags[tag] ?? 0)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
            }
        }
        .navigationTitle("Dream Tags")
    }
    
    private func getTags() -> [String: Int] {
        var tagCounts: [String: Int] = [:]
        
        for dream in dreams {
            for tag in dream.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts
    }
}

struct DreamsByTagView: View {
    let tag: String
    let dreams: [Dream]
    
    var body: some View {
        List {
            ForEach(dreams) { dream in
                NavigationLink(destination: DreamDetailView(dream: dream)) {
                    VStack(alignment: .leading) {
                        Text(dream.title)
                            .font(.headline)
                        
                        Text(formattedDate(dream.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 3)
                }
            }
        }
        .navigationTitle("Tag: \(tag)")
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DreamDetailView: View {
    let dream: Dream
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(dream.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(formattedDate(dream.timestamp))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !dream.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(dream.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                if let mood = dream.mood, !mood.isEmpty {
                    HStack {
                        Text("Mood: ")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(mood)
                            .font(.subheadline)
                    }
                }
                
                Text(dream.content)
                    .font(.body)
                    .padding(.top, 8)
                
                if dream.isInterpreted, let interpretation = dream.interpretation {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dream Interpretation")
                            .font(.headline)
                            .foregroundColor(.purple)
                            .padding(.top, 16)
                        
                        Text(interpretation)
                            .font(.body)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dream Details")
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}