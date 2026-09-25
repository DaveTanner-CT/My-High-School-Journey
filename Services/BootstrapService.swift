import Foundation
import SwiftData

@MainActor
enum BootstrapService {
    static func prepare(modelContext: ModelContext) throws {
        try ensureProfile(modelContext: modelContext)
        try ensureTilePreferences(modelContext: modelContext)
        try modelContext.save()
    }

    private static func ensureProfile(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<StudentProfile>()
        let profiles = try modelContext.fetch(descriptor)
        if profiles.isEmpty {
            modelContext.insert(StudentProfile())
        }
    }

    private static func ensureTilePreferences(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<TilePreference>()
        let existing = try modelContext.fetch(descriptor)
        let existingIDs = Set(existing.map(\.moduleID))

        for module in ModuleRegistry.modules where !existingIDs.contains(module.id) {
            modelContext.insert(
                TilePreference(
                    moduleID: module.id,
                    isEnabled: module.defaultEnabled,
                    sortOrder: module.defaultOrder
                )
            )
        }
    }
}
