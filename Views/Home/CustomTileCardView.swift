import SwiftUI

struct CustomTileCardView: View {
    let tile: CustomTile
    var itemCount: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: tile.systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Spacer(minLength: 8)

                if let itemCount {
                    Text("\(itemCount)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.primary.opacity(0.06), in: Capsule())
                }
            }

            Spacer(minLength: 4)

            Text(tile.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(tileSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: tile.isWide ? 120 : 142, alignment: .leading)
        .padding(18)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
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
