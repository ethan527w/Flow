//
//  HistoryInputView.swift
//  Flow
//
//  Created by Ethan Wu on 3/14/26.
//


import SwiftUI
import SwiftData

struct HistoryInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText: String = ""
    @State private var selectedDate: Date = .now
    
    // Focus state to automatically pop up keyboard
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date & Time Picker
                DatePicker(
                    "Record Time",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .padding()
                .background(Color(.systemGray6))
                
                Divider()
                
                // Text Input Area
                TextEditor(text: $inputText)
                    .focused($isInputFocused)
                    .padding()
                    .font(.body)
            }
            .navigationTitle("Add History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHistoricalRecord()
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                // Auto focus when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInputFocused = true
                }
            }
        }
    }
    
    private func saveHistoricalRecord() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Create a record with the user-selected timestamp
        let newRecord = FlowRecord(
            timestamp: selectedDate,
            content: trimmedText
        )
        
        modelContext.insert(newRecord)
        dismiss()
    }
}