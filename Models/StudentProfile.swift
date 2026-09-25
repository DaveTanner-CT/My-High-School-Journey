import Foundation
import SwiftData

extension JourneySchemaV1 {
    @Model
    final class StudentProfile {
        var id: UUID = UUID()
        var preferredName: String = ""
        var graduationYear: Int = Calendar.current.component(.year, from: Date()) + 4
        var schoolName: String = ""
        var createdAt: Date = Date()
        var updatedAt: Date = Date()

        init(
            preferredName: String = "",
            graduationYear: Int = Calendar.current.component(.year, from: Date()) + 4,
            schoolName: String = ""
        ) {
            self.id = UUID()
            self.preferredName = preferredName
            self.graduationYear = graduationYear
            self.schoolName = schoolName
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}
