//
//  FlowApp.swift
//  Flow
//
//  Created by Ethan Wu on 3/14/26.
//


import SwiftUI
import SwiftData

@main
struct FlowApp: App {
    // Setup SwiftData container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FlowRecord.self,
            Schedule.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    // Inject test data when app launches
                    DebugDataManager.generateTestData(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}