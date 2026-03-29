import Foundation

class AIService {
    static let shared = AIService()
    
    // 你的完美提示词
    private let systemPrompt = """
    You are a structured data extraction engine for the "Flow" journaling app. Analyze the user's daily journal entries and return one raw JSON object — no markdown, no prose, no explanation. Your response must start with "{" and end with "}".
    
    INPUT: A JSON object: {"date": "YYYY-MM-DD", "entries": [{"time": "HH:MM", "content": "...", "emoji": "...", "score": number|null}]}
    
    OUTPUT SCHEMA:
    {
     "keywords": string[3],
     "hourlyEnergy": { [hour: string]: number },
     "hourlyMood":   { [hour: string]: number },
     "inferredActivities": string[]
    }
    
    FIELD RULES:
    keywords — Exactly 3 English words/short phrases in Title Case summarizing the day's dominant state.
    hourlyEnergy — Map of hour → energy integer 0–10. Infer from text, emoji, and pacing. Key format: no leading zero, no colon ("8" ✓, "08" ✗, 8 ✗). OMIT the key entirely if that hour has no entries and no inferable signal. Never use null.
    hourlyMood — Same key format and omission rule as hourlyEnergy. If the entry has a non-null "score", use it directly (multiple scores in one hour → round the average). Otherwise infer from sentiment and emoji. Energy and mood are independent — do not conflate them.
    inferredActivities — Contiguous time blocks covering the full waking period, format "HH:MM-HH:MM: Label". No gaps allowed. If two entries are 60+ minutes apart, infer a plausible activity block to fill the interval using surrounding context and time of day.
    """
    
    // 用于解析 AI 返回的 JSON 的中间结构体 (DTO)
    private struct AIResponseDTO: Codable {
        let keywords: [String]
        let hourlyEnergy: [String: Int]
        let hourlyMood: [String: Int]
        let inferredActivities: [String]
    }
    
    // 生成 JSON Payload
    private func buildUserPayload(date: Date, records: [FlowRecord]) throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var entriesMap: [[String: Any]] = []
        for record in records {
            var entry: [String: Any] = [
                "time": timeFormatter.string(from: record.timestamp),
                "content": record.content
            ]
            if let emoji = record.emoji { entry["emoji"] = emoji }
            if let score = record.score { entry["score"] = score }
            entriesMap.append(entry)
        }
        
        let payload: [String: Any] = [
            "date": dateFormatter.string(from: date),
            "entries": entriesMap
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
    
    // 发起网络请求并返回 DailySummary 模型
    func generateSummary(for date: Date, records: [FlowRecord]) async throws -> DailySummary {
        let userJsonString = try buildUserPayload(date: date, records: records)
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Config.openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o", // 或者使用 gpt-4o-mini 以节省成本
            "response_format": ["type": "json_object"], // 强制返回 JSON
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userJsonString]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 解析 OpenAI 的外层结构
        let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = jsonResult?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let contentString = message["content"] as? String,
              let contentData = contentString.data(using: .utf8) else {
            throw NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API Response"])
        }
        
        // 解析为你规定的 JSON Schema
        let aiResponse = try JSONDecoder().decode(AIResponseDTO.self, from: contentData)
        
        // 转换 Key (String -> Int) 以匹配 SwiftData 模型
        var energyMap: [Int: Int] = [:]
        var moodMap: [Int: Int] = [:]
        
        for (key, value) in aiResponse.hourlyEnergy {
            if let intKey = Int(key) { energyMap[intKey] = value }
        }
        for (key, value) in aiResponse.hourlyMood {
            if let intKey = Int(key) { moodMap[intKey] = value }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 返回最终对象
        return DailySummary(
            dateString: dateFormatter.string(from: date),
            keywords: aiResponse.keywords,
            hourlyEnergy: energyMap,
            hourlyMood: moodMap,
            inferredActivities: aiResponse.inferredActivities
        )
    }
}
