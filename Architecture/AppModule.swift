import Foundation

struct AppModule: Identifiable, Hashable {
    enum TileSize: String, Hashable {
        case compact
        case wide
    }

    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let defaultEnabled: Bool
    let defaultOrder: Int
    let tileSize: TileSize
    let isSensitive: Bool
}
