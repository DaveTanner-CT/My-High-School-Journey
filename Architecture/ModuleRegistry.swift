import Foundation

enum ModuleRegistry {
    static let modules: [AppModule] = [
        AppModule(
            id: "journey",
            title: "My Journey",
            subtitle: "Moments worth remembering",
            systemImage: "sparkles.rectangle.stack",
            defaultEnabled: true,
            defaultOrder: 0,
            tileSize: .wide,
            isSensitive: false
        ),
        AppModule(
            id: "activities",
            title: "Activities",
            subtitle: "Clubs, teams, roles & more",
            systemImage: "person.3.fill",
            defaultEnabled: true,
            defaultOrder: 1,
            tileSize: .compact,
            isSensitive: false
        ),
        AppModule(
            id: "athletics",
            title: "Athletics",
            subtitle: "Sports, stats & milestones",
            systemImage: "figure.run",
            defaultEnabled: true,
            defaultOrder: 2,
            tileSize: .compact,
            isSensitive: false
        ),
        AppModule(
            id: "honors",
            title: "Honors",
            subtitle: "Awards and recognition",
            systemImage: "medal.fill",
            defaultEnabled: true,
            defaultOrder: 3,
            tileSize: .compact,
            isSensitive: false
        ),
        AppModule(
            id: "experiences",
            title: "Experiences",
            subtitle: "Jobs, service, programs & more",
            systemImage: "briefcase.fill",
            defaultEnabled: true,
            defaultOrder: 4,
            tileSize: .wide,
            isSensitive: false
        ),
        AppModule(
            id: "people",
            title: "People Who Know Me",
            subtitle: "Teachers, coaches, mentors & more",
            systemImage: "person.crop.circle.badge.checkmark",
            defaultEnabled: true,
            defaultOrder: 5,
            tileSize: .wide,
            isSensitive: false
        ),
        AppModule(
            id: "goals",
            title: "Goals",
            subtitle: "Things I want to work toward",
            systemImage: "target",
            defaultEnabled: true,
            defaultOrder: 6,
            tileSize: .compact,
            isSensitive: false
        ),
        AppModule(
            id: "reflections",
            title: "Private Reflections",
            subtitle: "A private place to think and remember",
            systemImage: "lock.fill",
            defaultEnabled: false,
            defaultOrder: 7,
            tileSize: .wide,
            isSensitive: true
        ),
        AppModule(
            id: "collegeVisits",
            title: "College Visits",
            subtitle: "Save visits, photos and impressions",
            systemImage: "building.columns.fill",
            defaultEnabled: false,
            defaultOrder: 8,
            tileSize: .wide,
            isSensitive: false
        ),
        AppModule(
            id: "recruiting",
            title: "Athletic Recruiting",
            subtitle: "Schools, coaches and next steps",
            systemImage: "sportscourt.fill",
            defaultEnabled: false,
            defaultOrder: 9,
            tileSize: .wide,
            isSensitive: false
        ),
        AppModule(
            id: "resume",
            title: "Resume",
            subtitle: "Build from your Journey",
            systemImage: "doc.text.fill",
            defaultEnabled: false,
            defaultOrder: 10,
            tileSize: .compact,
            isSensitive: false
        ),
        AppModule(
            id: "resources",
            title: "Trusted Resources",
            subtitle: "Official national resources",
            systemImage: "checkmark.seal.fill",
            defaultEnabled: true,
            defaultOrder: 11,
            tileSize: .wide,
            isSensitive: false
        )
    ]

    static func module(id: String) -> AppModule? {
        modules.first { $0.id == id }
    }
}
