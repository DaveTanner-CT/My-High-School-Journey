import SwiftUI

struct ModuleTileView: View {
    let module: AppModule
    var statusText: String? = nil
    var displayMode: HomeTileDisplayMode = .compact

    private var accentColor: Color {
        switch module.id {
        case "journey": return .indigo
        case "activities": return .blue
        case "athletics": return .green
        case "honors": return .orange
        case "experiences": return .teal
        case "people": return .purple
        case "goals": return .pink
        case "reflections": return .mint
        case "collegeVisits": return .cyan
        case "recruiting": return .orange
        case "resume": return .indigo
        case "resources": return .green
        default: return .blue
        }
    }

    var body: some View {
        tileCard
    }

    private var tileCard: some View {
        VStack(alignment: .leading, spacing: displayMode == .compact ? 8 : 12) {
            HStack(alignment: .top) {
                Image(systemName: module.systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(accentColor)

                Spacer(minLength: 8)

                if let statusText {
                    Text(statusText)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(accentColor.opacity(0.10), in: Capsule())
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
