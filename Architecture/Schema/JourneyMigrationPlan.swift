import SwiftData

enum JourneyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [JourneySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
