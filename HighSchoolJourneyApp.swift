import SwiftUI
import SwiftData

@main
struct HighSchoolJourneyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            StudentProfile.self,
            TilePreference.self,
            JourneyMoment.self,
            CustomTile.self,
            CustomTileItem.self
        ])
    }
}
