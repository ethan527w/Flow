//
//  Schedule.swift
//  Flow
//
//  Created by Ethan Wu on 3/14/26.
//


import Foundation
import SwiftData

@Model
final class Schedule {
    var title: String
    var startTime: Date
    var endTime: Date
    var colorHex: String // e.g., "#FF0000" for UI rendering
    
    init(title: String, startTime: Date, endTime: Date, colorHex: String) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.colorHex = colorHex
    }
}