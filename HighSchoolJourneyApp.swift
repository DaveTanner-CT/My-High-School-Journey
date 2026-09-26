import SwiftUI
import SwiftData
import GoogleSignIn

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
                .onOpenURL { url in
                    _ = GoogleOAuthService.shared.handleOpenURL(url)
                }
                .task {
                    if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                        _ = try? await GIDSignIn.sharedInstance.restorePreviousSignIn()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
