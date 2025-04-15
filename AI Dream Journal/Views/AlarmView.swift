//
//  AlarmView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

struct AlarmView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Alarm.time, order: .forward) var alarms: [Alarm]
    @State private var showAddAlarmSheet = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if alarms.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple.opacity(0.7))
                        
                        Text("No Dream Alarms")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Add an alarm to get notified when it's time to record your dreams")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button {
                            showAddAlarmSheet.toggle()
                        } label: {
                            Text("Add Alarm")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                } else {
                    List {
                        ForEach(alarms) { alarm in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(alarm.label)
                                        .font(.headline)

                                    HStack(spacing: 4) {
                                        Text(formattedTime(alarm.time))
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(alarm.isEnabled ? .primary : .secondary)
                                        
                                        Text("daily")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                .padding(.vertical, 4)

                                Spacer()

                                Toggle("", isOn: Binding(
                                    get: { alarm.isEnabled },
                                    set: { newValue in
                                        withAnimation {
                                            toggleAlarm(alarm, enabled: newValue)
                                        }
                                    }
                                ))
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingAlarm = alarm
                            }
                            .padding(.vertical, 4)
                            .background(alarm.isEnabled ? Color.clear : Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                        .onDelete(perform: deleteAlarms)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Dream Alarms")
            .toolbar {
                Button {
                    showAddAlarmSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddAlarmSheet) {
                AddAlarmView()
            }
            .sheet(item: $editingAlarm) { alarm in
                AddAlarmView(editMode: true, existingAlarm: alarm)
            }
            .safeAreaInset(edge: .bottom) {
                // Add spacing for the floating tab bar
                Spacer().frame(height: 70)
            }
        }
    }

    private func deleteAlarms(offsets: IndexSet) {
        for index in offsets {
            let alarm = alarms[index]
            // Also cancel any scheduled notifications
            AlarmScheduler.cancelAlarm(alarm)
            modelContext.delete(alarm)
        }
        try? modelContext.save()
    }

    private func toggleAlarm(_ alarm: Alarm, enabled: Bool) {
        alarm.isEnabled = enabled

        if enabled {
            AlarmScheduler.scheduleAlarm(alarm)
        } else {
            AlarmScheduler.cancelAlarm(alarm)
        }

        try? modelContext.save()
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
