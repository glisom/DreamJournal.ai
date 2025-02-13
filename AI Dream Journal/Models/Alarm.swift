//
//  Alarm.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//


import SwiftData
import Foundation

@Model
class Alarm {
    @Attribute(.unique) var id: UUID
    var time: Date
    var label: String
    var isEnabled: Bool
    
    init(id: UUID = UUID(), time: Date, label: String, isEnabled: Bool = false) {
        self.id = id
        self.time = time
        self.label = label
        self.isEnabled = isEnabled
    }
}