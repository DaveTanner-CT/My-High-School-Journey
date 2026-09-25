import Foundation
import SwiftData

extension JourneySchemaV1 {
    @Model
    final class CustomTileItem {
        var id: UUID = UUID()
        var tileID: UUID = UUID()
        var title: String = ""
        var itemDate: Date = Date()
        var notes: String = ""
        var linkURL: String = ""
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(tileID: UUID, title: String, itemDate: Date = Date(), notes: String = "", linkURL: String = "") {
            self.id = UUID()
            self.tileID = tileID
            self.title = title
            self.itemDate = itemDate
            self.notes = notes
            self.linkURL = linkURL
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}
