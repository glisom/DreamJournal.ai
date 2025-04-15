//
//  InterpretView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

struct InterpretView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.timestamp, order: .reverse) private var dreams: [Dream]
    @State private var selectedDream: Dream?
    @State private var interpretation: String?
    @State private var horoscope: String?
    @State private var isLoading = false
    @State private var showPaywall = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Content will go here
                // Dream selector
                if !dreams.isEmpty {
                    Menu {
                        ForEach(dreams) { dream in
                            Button(dream.title) {
                                selectedDream = dream
                                clearResults()
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedDream?.title ?? "Select a dream")
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                } else {
                    emptyStateView
                        .padding()
                }
                
                if let selectedDream = selectedDream {
                    // Analysis Actions
                    Picker("Analysis Type", selection: $selectedTab) {
                        Text("Dream Interpretation").tag(0)
                        Text("Horoscope").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            if selectedTab == 0 {
                                // Dream Interpretation Tab
                                dreamContent(selectedDream)
                                    .padding(.horizontal)
                                
                                if isLoading {
                                    ProgressView("Analyzing your dream...")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                } else if let interpretation = interpretation {
                                    interpretationView(interpretation)
                                } else {
                                    interpretButton
                                }
                            } else {
                                // Horoscope Tab
                                if isLoading {
                                    ProgressView("Generating your horoscope...")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                } else if let horoscope = horoscope {
                                    horoscopeView(horoscope)
                                } else {
                                    horoscopeButton
                                }
                            }
                        }
                        .padding(.bottom, 50)
                    }
                } else if !dreams.isEmpty {
                    // No dream selected yet
                    Text("Select a dream to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Interpret")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .safeAreaInset(edge: .bottom) {
                // Add spacing for the floating tab bar
                Spacer().frame(height: 70)
            }
        }
        .onAppear {
            if !dreams.isEmpty && selectedDream == nil {
                selectedDream = dreams.first
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("No Dreams to Interpret")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Record your dreams in the Journal tab, then come back to get personalized interpretations.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    private func dreamContent(_ dream: Dream) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dream.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(dream.timestamp, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(dream.content)
                .font(.body)
                .padding(.top, 5)
        }
    }
    
    private var interpretButton: some View {
        Button {
            interpretDream()
        } label: {
            Text("Interpret this Dream")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)
        }
        .padding()
    }
    
    private var horoscopeButton: some View {
        Button {
            getHoroscope()
        } label: {
            Text("Get Your Horoscope")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .cornerRadius(10)
        }
        .padding()
    }
    
    private func interpretationView(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Dream Interpretation")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
            }
            .padding(.horizontal)
            
            Text(text)
                .font(.body)
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
            if let dream = selectedDream, !dream.isInterpreted {
                Button {
                    saveDreamInterpretation(text)
                } label: {
                    Text("Save Interpretation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    private func horoscopeView(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Your Daily Horoscope")
                    .font(.headline)
                    .foregroundColor(.indigo)
                
                Spacer()
                
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.indigo)
            }
            .padding(.horizontal)
            
            Text(text)
                .font(.body)
                .padding()
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
    
    private func clearResults() {
        interpretation = nil
        horoscope = nil
    }
    
    private func interpretDream() {
        guard let dream = selectedDream else { return }
        
        isLoading = true
        
        AIService.shared.interpretDream(dream) { result in
            isLoading = false
            
            switch result {
            case .success(let interpretationText):
                interpretation = interpretationText
            case .failure(let error):
                print("Error interpreting dream: \(error.localizedDescription)")
                // Show error alert in a real app
            }
        }
    }
    
    private func getHoroscope() {
        isLoading = true
        
        AIService.shared.getHoroscope(includingDream: selectedDream) { result in
            isLoading = false
            
            switch result {
            case .success(let horoscopeText):
                horoscope = horoscopeText
            case .failure(let error):
                print("Error getting horoscope: \(error.localizedDescription)")
                // Show error alert in a real app
            }
        }
    }
    
    private func saveDreamInterpretation(_ text: String) {
        guard let dream = selectedDream else { return }
        
        dream.interpretation = text
        dream.isInterpreted = true
        
        try? modelContext.save()
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 70))
                .foregroundColor(.purple)
            
            Text("Unlock Premium Features")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "clock.fill", text: "Set unlimited alarm schedules")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track your dream patterns over time")
                FeatureRow(icon: "doc.on.doc", text: "Access your complete dream history")
                FeatureRow(icon: "sparkles", text: "Enhanced AI dream analysis")
                FeatureRow(icon: "moon.stars.fill", text: "Personalized horoscopes")
            }
            .padding(.vertical)
            
            VStack(spacing: 15) {
                Button {
                    // Handle subscription
                    dismiss()
                } label: {
                    Text("Subscribe - $4.99/month")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                
                Button {
                    // Handle one-time purchase
                    dismiss()
                } label: {
                    Text("Lifetime Access - $49.99")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.top)
            
            Button {
                dismiss()
            } label: {
                Text("Maybe Later")
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            Text("You can restore purchases at any time in the Profile tab")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}