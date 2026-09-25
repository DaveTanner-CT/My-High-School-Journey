import Foundation

struct ModuleRecordConfig {
    let moduleID: String
    let title: String
    let singularTitle: String
    let systemImage: String
    let titleLabel: String
    let dateLabel: String
    let typeLabel: String
    let categories: [String]
    let contextSectionTitle: String
    let organizationLabel: String?
    let roleLabel: String?
    let detailsLabel: String
    let reflectionLabel: String?
    let statusSectionTitle: String
    let statuses: [String]

    static let activities = ModuleRecordConfig(
        moduleID: "activities",
        title: "Activities",
        singularTitle: "Activity",
        systemImage: "person.3.fill",
        titleLabel: "Activity name",
        dateLabel: "Date",
        typeLabel: "Type",
        categories: ["Club", "Student leadership", "Arts", "Academic", "Community", "Other"],
        contextSectionTitle: "Where & How",
        organizationLabel: "Organization or group",
        roleLabel: "Role or position",
        detailsLabel: "What did you do?",
        reflectionLabel: "What did you learn or contribute?",
        statusSectionTitle: "Progress",
        statuses: []
    )

    static let athletics = ModuleRecordConfig(
        moduleID: "athletics",
        title: "Athletics",
        singularTitle: "Athletic Record",
        systemImage: "figure.run",
        titleLabel: "Sport or team",
        dateLabel: "Season or milestone date",
        typeLabel: "Type",
        categories: ["School team", "Club team", "Individual sport", "Training", "Camp or clinic", "Other"],
        contextSectionTitle: "Team & Role",
        organizationLabel: "School, team, or club",
        roleLabel: "Position, event, or level",
        detailsLabel: "Stats, milestones, or what happened",
        reflectionLabel: "What are you proud of or working on?",
        statusSectionTitle: "Progress",
        statuses: []
    )

    static let honors = ModuleRecordConfig(
        moduleID: "honors",
        title: "Honors",
        singularTitle: "Honor or Award",
        systemImage: "medal.fill",
        titleLabel: "Honor or award",
        dateLabel: "Date received",
        typeLabel: "Type",
        categories: ["Academic", "Athletic", "Leadership", "Service", "Arts", "Other"],
        contextSectionTitle: "Presented By",
        organizationLabel: "School or organization",
        roleLabel: nil,
        detailsLabel: "Why did you receive it?",
        reflectionLabel: nil,
        statusSectionTitle: "Progress",
        statuses: []
    )

    static let experiences = ModuleRecordConfig(
        moduleID: "experiences",
        title: "Experiences",
        singularTitle: "Experience",
        systemImage: "briefcase.fill",
        titleLabel: "Experience name",
        dateLabel: "Date",
        typeLabel: "Type",
        categories: ["Job", "Volunteer service", "Internship", "Summer program", "Independent project", "Other"],
        contextSectionTitle: "Where & How",
        organizationLabel: "Organization",
        roleLabel: "Role",
        detailsLabel: "What did you do?",
        reflectionLabel: "What did you learn?",
        statusSectionTitle: "Progress",
        statuses: []
    )

    static let people = ModuleRecordConfig(
        moduleID: "people",
        title: "People Who Know Me",
        singularTitle: "Person",
        systemImage: "person.crop.circle.badge.checkmark",
        titleLabel: "Person's name",
        dateLabel: "Last connected",
        typeLabel: "Relationship",
        categories: ["Teacher", "Coach", "Counselor", "Mentor", "Employer", "Community leader", "Other"],
        contextSectionTitle: "Connection",
        organizationLabel: "School or organization",
        roleLabel: "How do they know you?",
        detailsLabel: "What have you worked on or experienced together?",
        reflectionLabel: "What might they remember about you?",
        statusSectionTitle: "Recommendation",
        statuses: ["Stay in touch", "Could ask for recommendation", "Recommendation requested", "Recommendation received"]
    )


    static let collegeVisits = ModuleRecordConfig(
        moduleID: "collegeVisits",
        title: "College Visits",
        singularTitle: "College Visit",
        systemImage: "building.columns.fill",
        titleLabel: "College or university",
        dateLabel: "Visit date",
        typeLabel: "Visit type",
        categories: ["Campus tour", "Open house", "Information session", "Overnight visit", "Virtual visit", "Other"],
        contextSectionTitle: "Visit Details",
        organizationLabel: "Location or campus",
        roleLabel: "Who did you meet?",
        detailsLabel: "What stood out?",
        reflectionLabel: "How did this school feel to you?",
        statusSectionTitle: "Interest",
        statuses: ["Interested", "Researching", "Planning to apply", "Applied", "Not for me"]
    )

    static let recruiting = ModuleRecordConfig(
        moduleID: "recruiting",
        title: "Athletic Recruiting",
        singularTitle: "Recruiting Update",
        systemImage: "sportscourt.fill",
        titleLabel: "School or program",
        dateLabel: "Contact or event date",
        typeLabel: "Update type",
        categories: ["Coach contact", "Questionnaire", "Camp or clinic", "Campus visit", "Game or showcase", "Offer or interest", "Other"],
        contextSectionTitle: "Recruiting Details",
        organizationLabel: "Coach or contact",
        roleLabel: "Sport, position, or event",
        detailsLabel: "What happened or what was discussed?",
        reflectionLabel: "What do you want to remember or do next?",
        statusSectionTitle: "Recruiting Status",
        statuses: ["Interested", "Contacted", "Coach replied", "Visit planned", "Offer received", "Not pursuing"]
    )

    static let goals = ModuleRecordConfig(
        moduleID: "goals",
        title: "Goals",
        singularTitle: "Goal",
        systemImage: "target",
        titleLabel: "Goal",
        dateLabel: "Target date",
        typeLabel: "Area",
        categories: ["Academic", "Activity", "College", "Career", "Personal", "Other"],
        contextSectionTitle: "Details",
        organizationLabel: nil,
        roleLabel: nil,
        detailsLabel: "What will help you get there?",
        reflectionLabel: "Notes",
        statusSectionTitle: "Progress",
        statuses: ["Not started", "In progress", "Completed"]
    )

    static let all: [ModuleRecordConfig] = [activities, athletics, honors, experiences, people, goals, collegeVisits, recruiting]

    static func config(for moduleID: String) -> ModuleRecordConfig? {
        all.first { $0.moduleID == moduleID }
    }

    static func supportsRecords(_ moduleID: String) -> Bool {
        config(for: moduleID) != nil
    }
}
