import SwiftUI
import SwiftData

@main
struct HighSchoolJourneyApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema(versionedSchema: JourneySchemaV2.self)
            modelContainer = try ModelContainer(
                for: schema,
                migrationPlan: JourneyMigrationPlan.self
            )
        } catch {
            fatalError("Unable to create High School Journey data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
