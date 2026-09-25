import Foundation

struct HomeTileEntry: Identifiable {
    enum Kind {
        case builtIn(moduleID: String)
        case custom(tileID: UUID)
    }

    let id: String
    let sortOrder: Int
    let kind: Kind
}
