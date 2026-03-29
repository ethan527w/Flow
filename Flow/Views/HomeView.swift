import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Existing data
    @Query(sort: \FlowRecord.timestamp, order: .forward) private var allRecords: [FlowRecord]
    @Query private var schedules: [Schedule]
    
    // Date tracking
    @State private var currentDate: Date = .now
    
    // Menu
    @State private var showingMenu = false
    
    // AI Feature States
    @State private var showingLengthAlert = false
    @State private var isGeneratingAI = false
    @State private var currentSummary: DailySummary?
    
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Filters
    
    var todaysRecords: [FlowRecord] {
        allRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: currentDate) }
    }
    
    // Show AI button after 11PM OR when viewing past days
    var canShowAIButton: Bool {
        let isPastDate = !Calendar.current.isDateInToday(currentDate)
        let currentHour = Calendar.current.component(.hour, from: .now)
        return isPastDate || (Calendar.current.isDateInToday(currentDate) && currentHour >= 23)
    }
    
    // MARK: - UI
    
    var body: some View {
        VStack(spacing: 0) {
            
            // TOP BAR
            HStack {
                Button { showingMenu = true } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(dateString(for: currentDate))
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .opacity(0)
            }
            .padding()
            .sheet(isPresented: $showingMenu) { MenuView() }
            
            // TIMELINE + AI AREA
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        TimelineView(records: todaysRecords, schedules: schedules)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        // 🔵 AI SECTION
                        if canShowAIButton {
                            aiSection
                        }
                    }
                }
                .gesture(dateSwipeGesture)
                .onChange(of: todaysRecords.count) {
                    if let lastRecord = todaysRecords.last {
                        withAnimation {
                            proxy.scrollTo(lastRecord.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            InputBarView(currentDate: currentDate)
        }
        .alert("Data Too Long", isPresented: $showingLengthAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your entries exceed the 5000 character limit for AI analysis.")
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - AI Section UI
////////////////////////////////////////////////////////////

extension HomeView {
    
    private var aiSection: some View {
        VStack {
            if currentSummary == nil {
                Button(action: triggerAIAnalysis) {
                    HStack {
                        if isGeneratingAI {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isGeneratingAI ? "Analyzing Day..." : "Generate Daily AI Insights")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isGeneratingAI)
            } else {
                PlannedVsActualBar(summary: currentSummary!)
            }
        }
        .padding()
    }
}

////////////////////////////////////////////////////////////
// MARK: - Gestures
////////////////////////////////////////////////////////////

extension HomeView {
    
    private var dateSwipeGesture: some Gesture {
        DragGesture().onEnded { value in
            withAnimation {
                if value.translation.width > 50 {
                    currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } else if value.translation.width < -50 {
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - AI Logic
////////////////////////////////////////////////////////////

extension HomeView {
    
    private func triggerAIAnalysis() {
            // 计算当天所有文本和 Emoji 的大致字符长度，防止过载
            let totalChars = todaysRecords.reduce(0) { $0 + $1.content.count + ($1.emoji?.count ?? 0) }
            
            if totalChars > 5000 {
                showingLengthAlert = true
                return
            }
            
            isGeneratingAI = true
            Task {
                do {
                    // 调用真实 API
                    let summary = try await AIService.shared.generateSummary(for: currentDate, records: todaysRecords)
                    
                    await MainActor.run {
                        // 1. 保存进数据库，这样明天再滑回来还能看到
                        self.modelContext.insert(summary)
                        // 2. 更新当前 UI 状态
                        self.currentSummary = summary
                        self.isGeneratingAI = false
                    }
                } catch {
                    print("🚨 AI Request Failed: \(error.localizedDescription)")
                    await MainActor.run { self.isGeneratingAI = false }
                }
            }
        }
}

////////////////////////////////////////////////////////////
// MARK: - Date Formatter
////////////////////////////////////////////////////////////

extension HomeView {
    private func dateString(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

////////////////////////////////////////////////////////////
// MARK: - Planned vs Actual Bar
////////////////////////////////////////////////////////////

struct PlannedVsActualBar: View {
    var summary: DailySummary
    
    // 1. 获取日程数据 (计划)
    @Query(sort: \Schedule.startTime) private var allSchedules: [Schedule]
    
    // 动态解析 dateString 为特定日期，过滤出当天的日程
    var todaysPlannedSchedules: [Schedule] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let targetDate = formatter.date(from: summary.dateString) else { return [] }
        return allSchedules.filter { Calendar.current.isDate($0.startTime, inSameDayAs: targetDate) }
    }
    
    // 2. 将 AI 总结解析为 (时间范围, 内容) 格式
    private func parseInferredActivities() -> [(range: String, activity: String)] {
        return summary.inferredActivities.compactMap { activity in
            let components = activity.components(separatedBy: ": ")
            guard components.count >= 2 else { return nil }
            return (range: components[0], activity: components[1])
        }
    }
    
    // 3. 将 Dictoinary 转换并排序为 [(Hour, Score, Type)] 格式，供 Chart 使用
    private var sortedChartData: [(hour: Int, score: Int, type: String)] {
        var data: [(hour: Int, score: Int, type: String)] = []
        
        // 核心修正：确保小时排序正确
        for hour in summary.hourlyEnergy.keys.sorted() {
            if let energy = summary.hourlyEnergy[hour] {
                data.append((hour: hour, score: energy, type: "Energy"))
            }
        }
        
        for hour in summary.hourlyMood.keys.sorted() {
            if let mood = summary.hourlyMood[hour] {
                data.append((hour: hour, score: mood, type: "Mood"))
            }
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header: Keywords
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Day Review")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    ForEach(summary.keywords, id: \.self) { word in
                        Text(word)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Charts Area: Energy vs Mood
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text("Energy").font(.caption2).foregroundColor(.white.opacity(0.8))
                    Rectangle().fill(Color.cyan).frame(width: 8, height: 8) // Symbol 形状区分
                    Text("Mood").font(.caption2).foregroundColor(.white.opacity(0.8))
                }
                
                Chart(sortedChartData, id: \.type) { item in
                    // 修正 幽灵线问题：统一使用一个 sorted data，通过 type 区分线段
                    LineMark(
                        x: .value("Hour", String(item.hour) + ":00"),
                        y: .value("Score", item.score),
                        series: .value("Series", item.type) // 显式声明 Series 物理隔离
                    )
                    .interpolationMethod(.catmullRom) // 平滑
                    
                    // 为不同类型应用不同的 Symbol，物理隔离符号
                    PointMark(
                        x: .value("Hour", String(item.hour) + ":00"),
                        y: .value("Score", item.score)
                    )
                    .foregroundStyle(item.type == "Energy" ? .orange : .cyan)
                    .symbol {
                        if item.type == "Energy" {
                            Circle().strokeBorder(.orange, lineWidth: 2).background(Circle().fill(.white)).frame(width: 8, height: 8)
                        } else {
                            Rectangle().fill(.cyan).frame(width: 8, height: 8) // Mood 是方形
                        }
                    }
                }
                .chartYScale(domain: 0...10) // Y轴固定 0-10 分
                .frame(height: 120)
                .chartForegroundStyleScale([
                    "Energy": Color.orange, // 显式映射颜色，修复全橙
                    "Mood": Color.cyan
                ])
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel().foregroundStyle(.white.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(.white.opacity(0.2))
                        AxisValueLabel().foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            
            // Features 1: Inferred vs Planned Table
            VStack(alignment: .leading, spacing: 10) {
                Text("Time Use: Plan vs Actual")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                // 使用 Grid 布局制作表格
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 12) {
                    GridRow {
                        Text("Schedules (Plan)")
                            .font(.caption).bold().foregroundColor(.gray)
                        Text("AI Inferred (Actual)")
                            .font(.caption).bold().foregroundColor(.green)
                    }
                    
                    Divider().background(Color.white.opacity(0.3)).gridCellUnsizedAxes(.horizontal)
                    
                    ForEach(parseInferredActivities(), id: \.range) { activity in
                        GridRow {
                            // 左列: 计划 (这里渲染当天的 Schedules)
                            VStack(alignment: .leading, spacing: 4) {
                                // 查找时间上最接近的 Planned Schedule，这里暂时简化，直接显示用户设置的 Plan
                                // 实际开发需要做一个交叉比对逻辑
                                if todaysPlannedSchedules.isEmpty {
                                    Text("Free Time").font(.system(size: 11)).foregroundColor(.white.opacity(0.6))
                                } else {
                                    // 这里暂时只显示第一个，你需要完善交叉比对的算法
                                    let plan = todaysPlannedSchedules.first!
                                    Text(plan.title)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: plan.colorHex))
                                }
                            }
                            
                            // 右列: 实际 (渲染 AI 推断)
                            HStack(alignment: .top) {
                                Text(activity.range)
                                    .font(.system(size: 11))
                                    .bold()
                                    .foregroundColor(.green.opacity(0.8))
                                
                                Text(activity.activity)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(hex: "1A237E")) // 深蓝背景
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
