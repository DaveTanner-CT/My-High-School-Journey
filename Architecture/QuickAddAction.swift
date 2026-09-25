import Foundation

struct QuickAddAction: Identifiable, Hashable {
    enum Kind: Hashable {
        case addJourneyMoment
        case openModule(String)
    }

    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let actionLabel: String
    let kind: Kind
}

enum QuickAddRegistry {
    static func action(for module: AppModule) -> QuickAddAction {
        if module.id == "journey" {
            return QuickAddAction(
                id: "module:\(module.id)",
                title: module.title,
                subtitle: "Save a new Journey Moment",
                systemImage: module.systemImage,
                actionLabel: "Add",
                kind: .addJourneyMoment
            )
        }

        return QuickAddAction(
            id: "module:\(module.id)",
            title: module.title,
            subtitle: module.subtitle,
            systemImage: module.systemImage,
            actionLabel: "Open",
            kind: .openModule(module.id)
        )
    }
}
