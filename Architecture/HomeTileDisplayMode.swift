import Foundation

enum HomeTileDisplayMode: String, CaseIterable, Identifiable {
    case compact
    case wide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compact: return "Compact"
        case .wide: return "Wide"
        }
    }

    var systemImage: String {
        switch self {
        case .compact: return "square.grid.2x2"
        case .wide: return "rectangle.grid.1x2"
        }
    }
}
