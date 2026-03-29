//
//  DailySummary.swift
//  Flow
//
//  Created by Ethan Wu on 3/28/26.
//


import Foundation
import SwiftData

@Model
final class DailySummary {
    @Attribute(.unique) var dateString: String // 格式如 "2026-03-27"，确保一天只有一个总结
    var keywords: [String]
    var hourlyEnergy: [Int: Int] // 小时 (0-23) : 能量值 (0-10)
    var hourlyMood: [Int: Int]   // 小时 (0-23) : 心情值 (0-10)
    
    // AI 推断出的“实际”日程，可以用 JSON 字符串或 Codable 数组存储，为了简化这里存为字符串数组
    var inferredActivities: [String] 
    
    init(dateString: String, keywords: [String], hourlyEnergy: [Int: Int], hourlyMood: [Int: Int], inferredActivities: [String]) {
        self.dateString = dateString
        self.keywords = keywords
        self.hourlyEnergy = hourlyEnergy
        self.hourlyMood = hourlyMood
        self.inferredActivities = inferredActivities
    }
}
