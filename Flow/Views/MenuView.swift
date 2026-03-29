//
//  MenuView.swift
//  Flow
//
//  Created by Ethan Wu on 3/14/26.
//

import SwiftUI
import SwiftData

// MARK: - MENU ROOT
struct MenuView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Settings") {
                    Text("Settings View (Theme & Metrics) - Coming Soon")
                }
                
                NavigationLink("Schedule") {
                    ScheduleListView()
                }
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - NEW SCHEDULE LIST (DAY SWIPE VERSION)
//////////////////////////////////////////////////////////////

struct ScheduleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Schedule.startTime) private var allSchedules: [Schedule]
    
    @State private var currentDate: Date = .now
    @State private var showingAddSheet = false
    
    var todaysSchedules: [Schedule] {
        allSchedules.filter {
            Calendar.current.isDate($0.startTime, inSameDayAs: currentDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Date Switcher
            HStack {
                Button {
                    withAnimation {
                        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    }
                } label: {
                    Image(systemName: "chevron.left").padding()
                }
                
                Spacer()
                
                Text(dateString(for: currentDate))
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                    }
                } label: {
                    Image(systemName: "chevron.right").padding()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // MARK: Schedule List
            List {
                if todaysSchedules.isEmpty {
                    Text("No schedules for this day.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(todaysSchedules) { schedule in
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: schedule.colorHex))
                                .frame(width: 6)
                                .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(schedule.title)
                                    .font(.headline)
                                
                                Text("\(timeString(from: schedule.startTime)) - \(timeString(from: schedule.endTime))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteSchedule)
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        withAnimation {
                            if value.translation.width > 50 {
                                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                            } else if value.translation.width < -50 {
                                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                            }
                        }
                    }
            )
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddScheduleSheet(targetDate: currentDate)
        }
    }
    
    // MARK: Helpers
    private func deleteSchedule(offsets: IndexSet) {
        for index in offsets {
            let scheduleToDelete = todaysSchedules[index]
            modelContext.delete(scheduleToDelete)
        }
    }
    
    private func dateString(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

//////////////////////////////////////////////////////////////
// MARK: - ADD SCHEDULE SHEET
//////////////////////////////////////////////////////////////

struct AddScheduleSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var targetDate: Date
    
    @State private var title: String = ""
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedColor: Color = .blue
    
    init(targetDate: Date) {
        self.targetDate = targetDate
        let calendar = Calendar.current
        let defaultStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: targetDate) ?? targetDate
        let defaultEnd = calendar.date(byAdding: .hour, value: 1, to: defaultStart) ?? targetDate
        
        _startTime = State(initialValue: defaultStart)
        _endTime = State(initialValue: defaultEnd)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Title", text: $title)
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                ColorPicker("Theme Color", selection: $selectedColor)
            }
            .navigationTitle("New Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newSchedule = Schedule(
                            title: title,
                            startTime: startTime,
                            endTime: endTime,
                            colorHex: selectedColor.toHex() ?? "0000FF"
                        )
                        modelContext.insert(newSchedule)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
