import Foundation
import SwiftData

extension JourneySchemaV2 {
    @Model
    final class ModuleRecord {
        var id: UUID = UUID()
        var moduleID: String = ""
        var title: String = ""
        var recordDate: Date = Date()
        var category: String = ""
        var organization: String = ""
        var role: String = ""
        var details: String = ""
        var reflection: String = ""
        var status: String = ""
        var includeInExports: Bool = true
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(
            moduleID: String,
            title: String,
            recordDate: Date = Date(),
            category: String = "",
            organization: String = "",
            role: String = "",
            details: String = "",
            reflection: String = "",
            status: String = "",
            includeInExports: Bool = true
        ) {
            self.id = UUID()
            self.moduleID = moduleID
            self.title = title
            self.recordDate = recordDate
            self.category = category
            self.organization = organization
            self.role = role
            self.details = details
            self.reflection = reflection
            self.status = status
            self.includeInExports = includeInExports
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}
