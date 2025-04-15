//
//  JournalView.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import SwiftData
import SwiftUI

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.timestamp, order: .reverse) private var dreams: [Dream]
    @State private var showAddDreamSheet = false
    @State private var selectedDream: Dream?
    @Binding var showDreamEntry: Bool
    
    init(showDreamEntry: Binding<Bool> = .constant(false)) {
        self._showDreamEntry = showDreamEntry
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dreams.isEmpty {
                    emptyStateView
                } else {
                    dreamsList
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Add spacing for the floating tab bar
                Spacer().frame(height: 70)
            }
            .navigationTitle("Dream Journal")
            .toolbar {
                Button {
                    showAddDreamSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showAddDreamSheet) {
                DreamEntryView(isNewDream: true)
            }
            .sheet(item: $selectedDream) { dream in
                DreamEntryView(dream: dream, isNewDream: false)
            }
            .sheet(isPresented: $showDreamEntry) {
                DreamEntryView(isNewDream: true)
                    .onDisappear {
                        showDreamEntry = false
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 72))
                .foregroundColor(.blue)
            
            Text("No Dreams Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the + button to record your first dream")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                showAddDreamSheet = true
            } label: {
                Text("Record Dream")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var dreamsList: some View {
        List {
            ForEach(dreams) { dream in
                dreamRow(dream)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDream = dream
                    }
            }
            .onDelete(perform: deleteDreams)
        }
    }
    
    private func dreamRow(_ dream: Dream) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(dream.title)
                    .font(.headline)
                
                Spacer()
                
                Text(formattedDate(dream.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(dream.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
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
            
            if dream.isInterpreted {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    
                    Text("Interpreted")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
        }
    }
    
    private func deleteDreams(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dreams[index])
        }
        try? modelContext.save()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DreamEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var dream: Dream?
    var isNewDream: Bool
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var currentTag: String = ""
    @State private var tags: [String] = []
    @State private var mood: String = ""
    
    init(dream: Dream? = nil, isNewDream: Bool) {
        self.dream = dream
        self.isNewDream = isNewDream
        
        if let dream = dream {
            _title = State(initialValue: dream.title)
            _content = State(initialValue: dream.content)
            _tags = State(initialValue: dream.tags)
            _mood = State(initialValue: dream.mood ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Dream details") {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Describe your dream...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                    }
                    
                    TextField("How did you feel? (optional)", text: $mood)
                }
                
                Section("Tags") {
                    tagsView
                    
                    HStack {
                        TextField("Add a tag...", text: $currentTag)
                        
                        Button {
                            addTag()
                        } label: {
                            Text("Add")
                        }
                        .disabled(currentTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                Button {
                    saveDream()
                } label: {
                    Text("Save Dream")
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                         content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle(isNewDream ? "New Dream" : "Edit Dream")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var tagsView: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                HStack(spacing: 4) {
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    Button {
                        removeTag(tag)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.7))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            currentTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveDream() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMood = mood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : mood
        
        if !trimmedTitle.isEmpty && !trimmedContent.isEmpty {
            if isNewDream {
                let newDream = Dream(
                    title: trimmedTitle,
                    content: trimmedContent,
                    tags: tags,
                    mood: trimmedMood
                )
                modelContext.insert(newDream)
            } else if let existingDream = dream {
                existingDream.title = trimmedTitle
                existingDream.content = trimmedContent
                existingDream.tags = tags
                existingDream.mood = trimmedMood
            }
            
            try? modelContext.save()
            dismiss()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: .init(x: point.x, y: point.y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var bounds: CGSize = .zero
        var points: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var result = CGSize.zero
            var row: (width: CGFloat, height: CGFloat) = (.zero, .zero)
            var rowX: CGFloat = 0
            var rowY: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if rowX + size.width > maxWidth, rowX > 0 {
                    // Start a new row
                    rowY += row.height + spacing
                    row = (.zero, .zero)
                    rowX = 0
                }
                
                points.append(CGPoint(x: rowX, y: rowY))
                
                rowX += size.width + spacing
                row.width = rowX - spacing
                row.height = max(row.height, size.height)
                
                result.width = max(result.width, row.width)
                result.height = rowY + row.height
            }
            
            bounds = result
        }
    }
}