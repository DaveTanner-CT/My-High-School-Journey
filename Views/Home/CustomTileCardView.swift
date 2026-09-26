import SwiftUI

struct CustomTileCardView: View {
    let tile: CustomTile
    var itemCount: Int? = nil
    var displayMode: HomeTileDisplayMode = .compact

    private var accentColor: Color {
        switch tile.tileType {
        case "resource": return .green
        case "shortcut": return .indigo
        default: return .purple
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: displayMode == .compact ? 8 : 12) {
            HStack(alignment: .top) {
                Image(systemName: tile.systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(accentColor)

                Spacer(minLength: 8)

                if let itemCount {
                    Text("\(itemCount)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(accentColor.opacity(0.10), in: Capsule())
                }
            }

            Spacer(minLength: 2)

            Text(tile.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(tileSubtitle)
                .font(displayMode == .compact ? .caption : .subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(displayMode == .compact ? 14 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CustomTileShapeModifier(displayMode: displayMode))
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(accentColor.opacity(0.055))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(accentColor.opacity(0.42), lineWidth: 1.5)
        }
    }

    private var tileSubtitle: String {
        switch tile.tileType {
        case "resource": return "Open resource"
        case "shortcut": return "Shortcut"
        default:
            if let itemCount {
                return "\(itemCount) \(itemCount == 1 ? "item" : "items") saved"
            }
            return "My collection"
        }
    }
}

private struct CustomTileShapeModifier: ViewModifier {
    let displayMode: HomeTileDisplayMode

    @ViewBuilder
    func body(content: Content) -> some View {
        switch displayMode {
        case .compact:
            content.aspectRatio(1, contentMode: .fit)
        case .wide:
            content.frame(minHeight: 120)
        }
    }
}
