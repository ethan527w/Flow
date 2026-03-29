//
//  ToolboxView.swift
//  Flow
//
//  Created by Ethan Wu on 3/14/26.
//


import SwiftUI
import SwiftData

struct ToolboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 0 = Emoji, 1 = Score
    @State private var selectedTool = 0
    
    // Score State
    @State private var scoreValue: Double = 5.0
    
    // Sample Emojis
    let emojis = ["😁", "🙂", "😐", "😔", "😫", "😡", "😴", "🤩", "🤯", "😭", "🥳", "🤔"]
    
    // Grid layout for Emojis
    let columns = [GridItem(.adaptive(minimum: 60))]
    
    var body: some View {
        VStack(spacing: 20) {
            // Tool Selector
            Picker("Measurement Tool", selection: $selectedTool) {
                Text("Emoji").tag(0)
                Text("Score (1-10)").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 20)
            
            if selectedTool == 0 {
                // Tool 1: Emoji Picker
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: {
                                saveMeasurement(emoji: emoji, score: nil)
                            }) {
                                Text(emoji)
                                    .font(.system(size: 40))
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // Tool 2: Score Bar (1-10)
                VStack(spacing: 30) {
                    Text("\(Int(scoreValue))")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Slider(value: $scoreValue, in: 1...10, step: 1)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        saveMeasurement(emoji: nil, score: Int(scoreValue))
                    }) {
                        Text("Add to Timeline")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
    }
    
    // 保存记录并直接关闭面板
    private func saveMeasurement(emoji: String?, score: Int?) {
        // 创建一个没有文本内容的记录，仅包含测量数据
        let newRecord = FlowRecord(content: "", emoji: emoji, score: score)
        modelContext.insert(newRecord)
        dismiss()
    }
}