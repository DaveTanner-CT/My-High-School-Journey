import Foundation

struct ModuleRecordConfig {
    let moduleID: String
    let title: String
    let singularTitle: String
    let systemImage: String
    let titleLabel: String
    let dateLabel: String
    let categories: [String]
    let organizationLabel: String?
    let roleLabel: String?
    let detailsLabel: String
    let reflectionLabel: String?
    let statuses: [String]

    static let activities = ModuleRecordConfig(
        moduleID: "activities",
        title: "Activities",
        singularTitle: "Activity",
        systemImage: "person.3.fill",
        titleLabel: "Activity name",
        dateLabel: "Date",
        categories: ["Club", "Student leadership", "Arts", "Academic", "Community", "Other"],
        organizationLabel: "Organization or group",
        roleLabel: "Role or position",
        detailsLabel: "What did you do?",
        reflectionLabel: "What did you learn or contribute?",
        statuses: []
    )

    static let honors = ModuleRecordConfig(
        moduleID: "honors",
        title: "Honors",
        singularTitle: "Honor or Award",
        systemImage: "medal.fill",
        titleLabel: "Honor or award",
        dateLabel: "Date received",
        categories: ["Academic", "Athletic", "Leadership", "Service", "Arts", "Other"],
        organizationLabel: "Presented by",
        roleLabel: nil,
        detailsLabel: "Why did you receive it?",
        reflectionLabel: nil,
        statuses: []
    )

    static let experiences = ModuleRecordConfig(
        moduleID: "experiences",
        title: "Experiences",
        singularTitle: "Experience",
        systemImage: "briefcase.fill",
        titleLabel: "Experience name",
        dateLabel: "Date",
        categories: ["Job", "Volunteer service", "Internship", "Summer program", "Independent project", "Other"],
        organizationLabel: "Organization",
        roleLabel: "Role",
        detailsLabel: "What did you do?",
        reflectionLabel: "What did you learn?",
        statuses: []
    )

    static let goals = ModuleRecordConfig(
        moduleID: "goals",
        title: "Goals",
        singularTitle: "Goal",
        systemImage: "target",
        titleLabel: "Goal",
        dateLabel: "Target date",
        categories: ["Academic", "Activity", "College", "Career", "Personal", "Other"],
        organizationLabel: nil,
        roleLabel: nil,
        detailsLabel: "What will help you get there?",
        reflectionLabel: "Notes",
        statuses: ["Not started", "In progress", "Completed"]
    )

    static let all: [ModuleRecordConfig] = [activities, honors, experiences, goals]

    static func config(for moduleID: String) -> ModuleRecordConfig? {
        all.first { $0.moduleID == moduleID }
    }

    static func supportsRecords(_ moduleID: String) -> Bool {
        config(for: moduleID) != nil
    }
}
