import SwiftUI

struct TimelineView: View {
    var records: [FlowRecord]
    var schedules: [Schedule]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if records.isEmpty {
                Text("No entries for this day.")
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(records) { record in
                    let recordColor = colorFor(timestamp: record.timestamp)
                    
                    HStack(alignment: .top, spacing: 12) {
                        // The Vertical Line and Dot
                        VStack(spacing: 0) {
                            Circle()
                                .fill(recordColor)
                                .frame(width: 8, height: 8)
                                .padding(.top, 6) // Align dot with the first line of text
                            
                            // The connecting line
                            Rectangle()
                                .fill(recordColor.opacity(0.3))
                                .frame(width: 2)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 6) {
                            Text(timeString(from: record.timestamp))
                                .font(.caption)
                                .foregroundColor(recordColor)
                            
                            // 渲染 Emoji
                            if let emoji = record.emoji {
                                Text(emoji)
                                    .font(.system(size: 40))
                            }
                            
                            // 渲染分数
                            if let score = record.score {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                    Text("Mood: \(score)/10")
                                }
                                .font(.subheadline)
                                .bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(recordColor.opacity(0.15))
                                .foregroundColor(recordColor)
                                .cornerRadius(8)
                            }
                            
                            // 渲染普通文本（如果不为空）
                            if !record.content.isEmpty {
                                Text(record.content)
                                    .font(.body)
                                    .lineLimit(nil)
                            }
                        }
                        .padding(.bottom, 20) // Spacing before the next record
                        
                        Spacer()
                    }
                    // This fixedSize modifier ensures the vertical line stretches perfectly
                    // to match the dynamic height of the text content.
                    .fixedSize(horizontal: false, vertical: true)
                    .id(record.id)
                }
            }
        }
    }
    
    // Determine the color based on intersecting schedules
    // Determine the color based on strict Date intersection
        private func colorFor(timestamp: Date) -> Color {
            // Find the first schedule that contains this exact timestamp
            for schedule in schedules {
                // Check if the record's timestamp falls exactly between the start and end time
                if timestamp >= schedule.startTime && timestamp <= schedule.endTime {
                    return Color(hex: schedule.colorHex)
                }
            }
            return Color.primary // Fallback color if no schedule matches
        }
    
    // Format timestamp
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
