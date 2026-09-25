import Foundation
import SwiftData

extension JourneySchemaV1 {
    @Model
    final class JourneyMoment {
        var id: UUID = UUID()
        var title: String = ""
        var momentDate: Date = Date()
        var category: String = "General"
        var summary: String = ""
        var reflection: String = ""
        var gradeLevel: String = ""
        var isFeatured: Bool = true
        var includeInExports: Bool = true
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(
            title: String,
            momentDate: Date = Date(),
            category: String = "General",
            summary: String = "",
            reflection: String = "",
            gradeLevel: String = "",
            isFeatured: Bool = true,
            includeInExports: Bool = true
        ) {
            self.id = UUID()
            self.title = title
            self.momentDate = momentDate
            self.category = category
            self.summary = summary
            self.reflection = reflection
            self.gradeLevel = gradeLevel
            self.isFeatured = isFeatured
            self.includeInExports = includeInExports
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}

import Foundation
import SwiftData

extension JourneySchemaV2 {
    @Model
    final class JourneyMoment {
        var id: UUID = UUID()
        var title: String = ""
        var momentDate: Date = Date()
        var category: String = "General"
        var summary: String = ""
        var reflection: String = ""
        var gradeLevel: String = ""
        var isFeatured: Bool = true
        var includeInExports: Bool = true
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(
            title: String,
            momentDate: Date = Date(),
            category: String = "General",
            summary: String = "",
            reflection: String = "",
            gradeLevel: String = "",
            isFeatured: Bool = true,
            includeInExports: Bool = true
        ) {
            self.id = UUID()
            self.title = title
            self.momentDate = momentDate
            self.category = category
            self.summary = summary
            self.reflection = reflection
            self.gradeLevel = gradeLevel
            self.isFeatured = isFeatured
            self.includeInExports = includeInExports
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}
