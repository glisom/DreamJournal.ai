//
//  Dream.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import Foundation
import SwiftData

@Model
final class Dream {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var timestamp: Date
    var tags: [String]
    var mood: String?
    var isInterpreted: Bool
    var interpretation: String?
    
    init(id: UUID = UUID(), title: String, content: String, timestamp: Date = Date(), tags: [String] = [], mood: String? = nil, isInterpreted: Bool = false, interpretation: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.tags = tags
        self.mood = mood
        self.isInterpreted = isInterpreted
        self.interpretation = interpretation
    }
}