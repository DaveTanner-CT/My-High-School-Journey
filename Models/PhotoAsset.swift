import Foundation
import SwiftData

extension JourneySchemaV1 {
    @Model
    final class PhotoAsset {
        var id: UUID = UUID()
        var ownerType: String = ""
        var ownerID: UUID = UUID()
        var imageFilename: String = ""
        var thumbnailFilename: String = ""
        var caption: String = ""
        var sortOrder: Int = 0
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(
            ownerType: String,
            ownerID: UUID,
            imageFilename: String,
            thumbnailFilename: String,
            caption: String = "",
            sortOrder: Int = 0
        ) {
            self.id = UUID()
            self.ownerType = ownerType
            self.ownerID = ownerID
            self.imageFilename = imageFilename
            self.thumbnailFilename = thumbnailFilename
            self.caption = caption
            self.sortOrder = sortOrder
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}

enum PhotoOwnerType {
    static let journeyMoment = "journeyMoment"
    static let customTileItem = "customTileItem"
}
