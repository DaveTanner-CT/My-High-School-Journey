import SwiftData

enum JourneySchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            JourneySchemaV2.StudentProfile.self,
            JourneySchemaV2.TilePreference.self,
            JourneySchemaV2.JourneyMoment.self,
            JourneySchemaV2.CustomTile.self,
            JourneySchemaV2.CustomTileItem.self,
            JourneySchemaV2.PhotoAsset.self,
            JourneySchemaV2.ModuleRecord.self
        ]
    }
}
