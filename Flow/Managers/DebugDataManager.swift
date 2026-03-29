import Foundation
import SwiftData

@MainActor
class DebugDataManager {
    static func generateTestData(context: ModelContext) {
        let calendar = Calendar.current
        let year = 2026
        let month = 3
        let day = 27
        
        // 1. 专门检查 3 月 27 日是否已经生成过数据，避免每次启动重复添加
        guard let targetDate = calendar.date(from: DateComponents(year: year, month: month, day: day)),
              let nextDate = calendar.date(byAdding: .day, value: 1, to: targetDate) else { return }
        
        let predicate = #Predicate<FlowRecord> { record in
            record.timestamp >= targetDate && record.timestamp < nextDate
        }
        let descriptor = FetchDescriptor<FlowRecord>(predicate: predicate)
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else {
            print("March 27 data already exists. Skipping generation.")
            return
        }
        
        // 2. 更真实、错开的用户输入模拟数据
        // 格式: (时, 分, 文本, Emoji, 分数)
        let mockEntries: [(Int, Int, String, String?, Int?)] = [
            // 早上：先写了文字，过两分钟补了一个 Emoji
            (8, 15, "Woke up feeling a bit groggy today. The alarm went off at 7, but I snoozed it multiple times.", nil, nil),
            (8, 17, "", "🥱", nil),
            
            // 开始工作：单独打了一个心情分数，过一会儿写了状态
            (9, 30, "", nil, 7),
            (9, 32, "Coffee is finally kicking in. Managed to fix the alignment bug. Feeling much more focused now.", nil, nil),
            
            // 中午：文字和 Emoji 结合（模拟用户在键盘里直接打出了 Emoji）
            (11, 45, "Just wrapped up a long design sync. Taking a short walk to clear my head before lunch.", "🚶‍♂️", nil),
            
            // 下午：纯打分
            (13, 10, "", nil, 8),
            
            // 遇到 Bug 的挫败感：先发个 Emoji 宣泄，再写字
            (15, 20, "", "🤯", nil),
            (15, 22, "Hit a major roadblock with the Core Data migration. Staring at the Xcode console...", nil, nil),
            
            // 解决问题：记录文字并附带一个很高的打分
            (16, 50, "Finally solved the migration crash! Celebrating with a quick stretch.", nil, 9),
            
            // 晚上：生活记录
            (18, 30, "Logging off for the day. Going to cook some pasta.", "🍝", nil),
            (20, 15, "Dinner was excellent. Brain is in low-power mode.", nil, 6),
            (22, 00, "Did a quick 15-minute meditation.", "🧘‍♂️", nil),
            (23, 30, "Time for bed. Hoping to wake up fresh tomorrow.", nil, 5)
        ]
        
        // 3. 写入数据库
        for entry in mockEntries {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = entry.0
            components.minute = entry.1
            
            if let date = calendar.date(from: components) {
                let record = FlowRecord(timestamp: date, content: entry.2, emoji: entry.3, score: entry.4)
                context.insert(record)
            }
        }
        
        do {
            try context.save()
            print("Successfully injected realistic test data for Mar 27.")
        } catch {
            print("Failed to save test data: \(error.localizedDescription)")
        }
    }
}
