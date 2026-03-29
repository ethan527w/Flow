import SwiftUI
import SwiftData

struct InputBarView: View {
    @Environment(\.modelContext) private var modelContext
    
    @FocusState var isFocused: Bool
    @State private var inputText: String = ""
    
    @State private var showingHistoryInput = false
    // 新增：控制工具箱弹出的状态
    @State private var showingToolbox = false
    
    var currentDate: Date
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // Feature 5: Toolbox Button
            Button(action: {
                // 收起键盘，避免键盘和半屏菜单遮挡
                isFocused = false
                showingToolbox = true
            }) {
                Image(systemName: "square.grid.2x2")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Text Input
            TextField("What's on your mind?", text: $inputText, axis: .vertical)
                .focused($isFocused)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .lineLimit(1...5)
            
            // Action Button Logic
            if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: { showingHistoryInput = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 6)
            } else {
                Button(action: saveRecord) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 6)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isFocused = true }
        }
        .sheet(isPresented: $showingHistoryInput) { HistoryInputView() }
        // 绑定工具箱视图，并设置为半屏高度
        .sheet(isPresented: $showingToolbox) {
            ToolboxView()
                .presentationDetents([.height(350)])
        }
    }
    
    private func saveRecord() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        let newRecord = FlowRecord(content: trimmedText)
        modelContext.insert(newRecord)
        inputText = ""
    }
}
