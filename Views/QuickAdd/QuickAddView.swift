import SwiftUI
import SwiftData

struct QuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var preferences: [TilePreference]
    @Query private var customTiles: [CustomTile]

    private var entries: [QuickAddTileEntry] {
        let builtIns = preferences
            .filter(\.isEnabled)
            .compactMap { preference -> QuickAddTileEntry? in
                guard let module = ModuleRegistry.module(id: preference.moduleID) else {
                    return nil
                }

                return QuickAddTileEntry(
                    id: "module:\(module.id)",
                    sortOrder: preference.sortOrder,
                    kind: .builtIn(module)
                )
            }

        let customs = customTiles
            .filter(\.isEnabled)
            .map { tile in
                QuickAddTileEntry(
                    id: "custom:\(tile.id.uuidString)",
                    sortOrder: tile.sortOrder,
                    kind: .custom(tile)
                )
            }

        return (builtIns + customs).sorted {
            if $0.sortOrder == $1.sortOrder {
                return $0.id < $1.id
            }
            return $0.sortOrder < $1.sortOrder
        }
    }

    var body: some View {
        let quickAddEntries = entries

        return NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quick Add")
                            .font(.largeTitle.bold())

                        Text("Choose any tile from your Home screen.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)

                    if quickAddEntries.isEmpty {
                        ContentUnavailableView(
                            "No Home tiles are enabled",
                            systemImage: "square.grid.2x2",
                            description: Text("Turn on tiles in Settings to see them here.")
                        )
                    } else {
                        ForEach(0..<quickAddEntries.count, id: \.self) { index in
                            destination(for: quickAddEntries[index])
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

    @ViewBuilder
    private func destination(for entry: QuickAddTileEntry) -> some View {
        switch entry.kind {
        case .builtIn(let module):
            let action = QuickAddRegistry.action(for: module)

            switch action.kind {
            case .addJourneyMoment:
                NavigationLink {
                    AddJourneyMomentView()
                } label: {
                    QuickAddCard(
                        title: action.title,
                        subtitle: action.subtitle,
                        systemImage: action.systemImage,
                        actionLabel: action.actionLabel
                    )
                }
                .buttonStyle(.plain)

            case .addModuleRecord(let moduleID):
                if let config = ModuleRecordConfig.config(for: moduleID) {
                    NavigationLink {
                        AddEditModuleRecordView(config: config)
                    } label: {
                        QuickAddCard(
                            title: action.title,
                            subtitle: action.subtitle,
                            systemImage: action.systemImage,
                            actionLabel: action.actionLabel
                        )
                    }
                    .buttonStyle(.plain)
                }

            case .openModule(let moduleID):
                NavigationLink {
                    AppRouteDestinationView(route: .module(moduleID))
                } label: {
                    QuickAddCard(
                        title: action.title,
                        subtitle: action.subtitle,
                        systemImage: action.systemImage,
                        actionLabel: action.actionLabel
                    )
                }
                .buttonStyle(.plain)
            }

        case .custom(let tile):
            customDestination(for: tile)
        }
    }

    @ViewBuilder
    private func customDestination(for tile: CustomTile) -> some View {
        if tile.tileType == "collection" {
            NavigationLink {
                AddCustomTileItemView(
                    tileID: tile.id,
                    tileTitle: tile.title
                )
            } label: {
                QuickAddCard(
                    title: tile.title,
                    subtitle: "Add an item to this collection",
                    systemImage: tile.systemImage,
                    actionLabel: "Add"
                )
            }
            .buttonStyle(.plain)
        } else if tile.tileType == "resource",
                  let url = URL(string: tile.resourceURL),
                  !tile.resourceURL.isEmpty {
            Link(destination: url) {
                QuickAddCard(
                    title: tile.title,
                    subtitle: "Open this resource",
                    systemImage: tile.systemImage,
                    actionLabel: "Open"
                )
            }
            .buttonStyle(.plain)
        } else if tile.tileType == "shortcut", !tile.targetModuleID.isEmpty {
            NavigationLink {
                AppRouteDestinationView(route: .module(tile.targetModuleID))
            } label: {
                QuickAddCard(
                    title: tile.title,
                    subtitle: "Open this shortcut",
                    systemImage: tile.systemImage,
                    actionLabel: "Open"
                )
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink {
                CustomCollectionView(tileID: tile.id)
            } label: {
                QuickAddCard(
                    title: tile.title,
                    subtitle: "Open this tile",
                    systemImage: tile.systemImage,
                    actionLabel: "Open"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct QuickAddTileEntry {
    enum Kind {
        case builtIn(AppModule)
        case custom(CustomTile)
    }

    let id: String
    let sortOrder: Int
    let kind: Kind
}

private struct QuickAddCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let actionLabel: String

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
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Text(actionLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

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
