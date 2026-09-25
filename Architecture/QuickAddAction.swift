import Foundation

struct QuickAddAction: Identifiable, Hashable {
    enum Kind: Hashable {
        case journeyMoment
    }

    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let kind: Kind
}

enum QuickAddRegistry {
    static let builtInActions: [QuickAddAction] = [
        QuickAddAction(
            id: "journeyMoment",
            title: "Journey Moment",
            subtitle: "Save something worth remembering",
            systemImage: "sparkles.rectangle.stack",
            kind: .journeyMoment
        )
    ]
}
