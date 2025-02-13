//
//  AddAlarmView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var label: String = ""
    @State private var alarmTime: Date = Date()
    @State private var isEnabled: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Alarm Label", text: $label)
                    DatePicker("Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
                }

                Toggle("Enabled", isOn: $isEnabled)

                Button("Save") {
                    saveAlarm()
                }
            }
            .navigationTitle("New Alarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveAlarm() {
        let alarm = Alarm(time: alarmTime, label: label, isEnabled: isEnabled)
        modelContext.insert(alarm)

        // Immediately schedule if the user toggles it on
        if isEnabled {
            AlarmScheduler.scheduleAlarm(alarm)
        }

        try? modelContext.save()
        dismiss()
    }
}
