import Foundation
import SwiftData

extension JourneySchemaV1 {
    @Model
    final class CustomTile {
        var id: UUID = UUID()
        var title: String = ""
        var systemImage: String = "square.grid.2x2.fill"
        var tileType: String = "collection"
        var resourceURL: String = ""
        var targetModuleID: String = ""
        var isEnabled: Bool = true
        var isWide: Bool = false
        var sortOrder: Int = 1000
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(
            title: String,
            systemImage: String = "square.grid.2x2.fill",
            tileType: String = "collection",
            resourceURL: String = "",
            targetModuleID: String = "",
            isEnabled: Bool = true,
            isWide: Bool = false,
            sortOrder: Int = 1000
        ) {
            self.id = UUID()
            self.title = title
            self.systemImage = systemImage
            self.tileType = tileType
            self.resourceURL = resourceURL
            self.targetModuleID = targetModuleID
            self.isEnabled = isEnabled
            self.isWide = isWide
            self.sortOrder = sortOrder
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}
