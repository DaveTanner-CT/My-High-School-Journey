import SwiftData

enum JourneyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [JourneySchemaV1.self, JourneySchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: JourneySchemaV1.self,
                toVersion: JourneySchemaV2.self
            )
        ]
    }
}
