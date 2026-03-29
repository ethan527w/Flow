//
//  FlowRecord.swift
//  Flow
//
//  Created by Ethan Wu on 3/14/26.
//


import Foundation
import SwiftData

@Model
final class FlowRecord {
    var timestamp: Date
    var content: String
    var emoji: String?
    var score: Int? // 1-10 rating
    
    init(timestamp: Date = .now, content: String, emoji: String? = nil, score: Int? = nil) {
        self.timestamp = timestamp
        self.content = content
        self.emoji = emoji
        self.score = score
    }
}