import SwiftData

enum JourneySchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            JourneySchemaV1.StudentProfile.self,
            JourneySchemaV1.TilePreference.self,
            JourneySchemaV1.JourneyMoment.self,
            JourneySchemaV1.CustomTile.self,
            JourneySchemaV1.CustomTileItem.self,
            JourneySchemaV1.PhotoAsset.self
        ]
    }
}
