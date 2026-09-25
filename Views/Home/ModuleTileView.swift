import SwiftUI

struct ModuleTileView: View {
    let module: AppModule
    var statusText: String? = nil
    var displayMode: HomeTileDisplayMode = .compact

    var body: some View {
        tileCard
    }

    private var tileCard: some View {
        VStack(alignment: .leading, spacing: displayMode == .compact ? 8 : 12) {
            HStack(alignment: .top) {
                Image(systemName: module.systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)

                Spacer(minLength: 8)

                if let statusText {
                    Text(statusText)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(.primary.opacity(0.06), in: Capsule())
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }

            Spacer(minLength: 2)

            Text(module.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(module.subtitle)
                .font(displayMode == .compact ? .caption : .subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(displayMode == .compact ? 2 : 3)
        }
        .padding(displayMode == .compact ? 14 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(TileShapeModifier(displayMode: displayMode))
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct TileShapeModifier: ViewModifier {
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
