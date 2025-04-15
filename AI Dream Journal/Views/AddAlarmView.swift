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

    @State private var label: String
    @State private var alarmTime: Date
    @State private var isEnabled: Bool
    @State private var showConfirmation = false
    
    // For editing existing alarms
    private var editMode: Bool
    private var existingAlarm: Alarm?
    
    // Initialization for new alarm
    init() {
        self._label = State(initialValue: "")
        self._alarmTime = State(initialValue: Date())
        self._isEnabled = State(initialValue: true)
        self.editMode = false
        self.existingAlarm = nil
    }
    
    // Initialization for editing existing alarm
    init(editMode: Bool, existingAlarm: Alarm) {
        self._label = State(initialValue: existingAlarm.label)
        self._alarmTime = State(initialValue: existingAlarm.time)
        self._isEnabled = State(initialValue: existingAlarm.isEnabled)
        self.editMode = editMode
        self.existingAlarm = existingAlarm
    }

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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Time picker with large display
                        VStack {
                            Text(timeString)
                                .font(.system(size: 60, weight: .semibold))
                                .padding(.top, 30)
                                .foregroundColor(.purple)
                            
                            DatePicker("", selection: $alarmTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                        
                        VStack(spacing: 16) {
                            // Label section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Label")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                HStack {
                                    Image(systemName: "tag")
                                        .foregroundColor(.purple)
                                        .frame(width: 30)
                                    TextField("Dream Alarm Label", text: $label)
                                }
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Settings section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Settings")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.purple)
                                        .frame(width: 30)
                                        
                                    Toggle("Enabled", isOn: $isEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                                }
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Buttons section
                            if editMode {
                                HStack(spacing: 12) {
                                    Button(action: saveAlarm) {
                                        HStack {
                                            Spacer()
                                            Text("Update")
                                                .fontWeight(.semibold)
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .background(Color.purple.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity)
                                    
                                    Button(action: deleteAlarm) {
                                        HStack {
                                            Spacer()
                                            Text("Delete")
                                                .fontWeight(.semibold)
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            } else {
                                Button(action: saveAlarm) {
                                    HStack {
                                        Spacer()
                                        Text("Save")
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.bottom, 20)
                }
                
                // Confirmation overlay
                if showConfirmation {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .overlay(
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                Text(editMode ? "Alarm Updated" : "Alarm Saved")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .padding()
                            }
                            .padding(30)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        )
                        .onAppear {
                            // Dismiss after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                }
            }
            .navigationTitle(editMode ? "Edit Alarm" : "New Alarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Computed property for formatted time string
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: alarmTime)
    }
    
    private func saveAlarm() {
        if editMode, let existingAlarm = existingAlarm {
            // Update existing alarm
            existingAlarm.label = label
            existingAlarm.time = alarmTime
            
            // Only update scheduling if the enabled state has changed
            if existingAlarm.isEnabled != isEnabled {
                existingAlarm.isEnabled = isEnabled
                
                if isEnabled {
                    AlarmScheduler.scheduleAlarm(existingAlarm)
                } else {
                    AlarmScheduler.cancelAlarm(existingAlarm)
                }
            } else if isEnabled {
                // Reschedule if enabled and time or other properties changed
                AlarmScheduler.cancelAlarm(existingAlarm)
                AlarmScheduler.scheduleAlarm(existingAlarm)
            }
        } else {
            // Create new alarm
            let alarm = Alarm(time: alarmTime, label: label.isEmpty ? "Dream Alarm" : label, isEnabled: isEnabled)
            modelContext.insert(alarm)

            // Immediately schedule if the user toggles it on
            if isEnabled {
                AlarmScheduler.scheduleAlarm(alarm)
            }
        }

        try? modelContext.save()
        
        // Show confirmation before dismissing
        withAnimation {
            showConfirmation = true
        }
    }
    
    private func deleteAlarm() {
        if let alarm = existingAlarm {
            // Cancel any scheduled notifications
            AlarmScheduler.cancelAlarm(alarm)
            modelContext.delete(alarm)
            try? modelContext.save()
            dismiss()
        }
    }
}
