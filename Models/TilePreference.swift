import Foundation
import SwiftData

@Model
final class TilePreference {
    var id: UUID = UUID()
    var moduleID: String = ""
    var isEnabled: Bool = true
    var sortOrder: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(moduleID: String, isEnabled: Bool, sortOrder: Int) {
        self.id = UUID()
        self.moduleID = moduleID
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
