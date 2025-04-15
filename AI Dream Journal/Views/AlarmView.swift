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

    var body: some View {
        NavigationView {
            List {
                ForEach(alarms) { alarm in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(alarm.label)
                                .font(.headline)

                            Text(formattedTime(alarm.time))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { alarm.isEnabled },
                            set: { newValue in
                                toggleAlarm(alarm, enabled: newValue)
                            }
                        ))
                        .labelsHidden()
                    }
                }
                .onDelete(perform: deleteAlarms)
            }
            .navigationTitle("Alarms")
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
