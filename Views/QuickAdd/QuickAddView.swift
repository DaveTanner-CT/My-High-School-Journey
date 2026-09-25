import SwiftUI
import SwiftData

struct QuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomTile.sortOrder) private var customTiles: [CustomTile]

    private var collectionTiles: [CustomTile] {
        customTiles.filter { $0.isEnabled && $0.tileType == "collection" }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quick Add")
                            .font(.largeTitle.bold())
                        Text("Save something now. You can add more detail later.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)

                    ForEach(QuickAddRegistry.builtInActions) { action in
                        switch action.kind {
                        case .journeyMoment:
                            NavigationLink {
                                AddJourneyMomentView()
                            } label: {
                                QuickAddCard(
                                    title: action.title,
                                    subtitle: action.subtitle,
                                    systemImage: action.systemImage
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !collectionTiles.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("My Custom Collections")
                                .font(.headline)
                                .padding(.top, 8)

                            ForEach(collectionTiles) { tile in
                                NavigationLink {
                                    AddCustomTileItemView(
                                        tileID: tile.id,
                                        tileTitle: tile.title
                                    )
                                } label: {
                                    QuickAddCard(
                                        title: tile.title,
                                        subtitle: "Add to my collection",
                                        systemImage: tile.systemImage
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct QuickAddCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 34, height: 34)
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}
