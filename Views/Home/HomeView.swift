import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [StudentProfile]
    @Query private var preferences: [TilePreference]
    @Query private var customTiles: [CustomTile]
    @Query(sort: \JourneyMoment.momentDate, order: .reverse) private var moments: [JourneyMoment]

    private var preferredName: String {
        let trimmed = profiles.first?.preferredName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "there" : trimmed
    }

    private var visibleEntries: [HomeTileEntry] {
        let builtIns = preferences
            .filter(\.isEnabled)
            .map {
                HomeTileEntry(
                    id: "module:\($0.moduleID)",
                    sortOrder: $0.sortOrder,
                    kind: .builtIn(moduleID: $0.moduleID)
                )
            }

        let customs = customTiles
            .filter(\.isEnabled)
            .map {
                HomeTileEntry(
                    id: "custom:\($0.id.uuidString)",
                    sortOrder: $0.sortOrder,
                    kind: .custom(tileID: $0.id)
                )
            }

        return (builtIns + customs).sorted {
            if $0.sortOrder == $1.sortOrder { return $0.id < $1.id }
            return $0.sortOrder < $1.sortOrder
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header

                if let latest = moments.first {
                    latestMomentCard(latest)
                }

                VStack(spacing: 14) {
                    ForEach(visibleEntries) { entry in
                        tile(for: entry)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 32)
        }
        .navigationTitle("High School Journey")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppRoute.self) { route in
            destination(for: route)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hi, \(preferredName)")
                .font(.largeTitle.bold())
            Text("Keep building the story you'll want later.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    private func latestMomentCard(_ moment: JourneyMoment) -> some View {
        NavigationLink(value: AppRoute.module("journey")) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Latest from My Journey", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(moment.title)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                if !moment.summary.isEmpty {
                    Text(moment.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Text(moment.momentDate, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func tile(for entry: HomeTileEntry) -> some View {
        switch entry.kind {
        case .builtIn(let moduleID):
            if let module = ModuleRegistry.module(id: moduleID) {
                NavigationLink(value: AppRoute.module(module.id)) {
                    ModuleTileView(module: module)
                }
                .buttonStyle(.plain)
            }

        case .custom(let tileID):
            if let tile = customTiles.first(where: { $0.id == tileID }) {
                if tile.tileType == "resource", let url = URL(string: tile.resourceURL), !tile.resourceURL.isEmpty {
                    Link(destination: url) {
                        CustomTileCardView(tile: tile)
                    }
                    .buttonStyle(.plain)
                } else if tile.tileType == "shortcut", !tile.targetModuleID.isEmpty {
                    NavigationLink(value: AppRoute.module(tile.targetModuleID)) {
                        CustomTileCardView(tile: tile)
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(value: AppRoute.customTile(tile.id)) {
                        CustomTileCardView(tile: tile)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .module(let id):
            if id == "journey" {
                JourneyView()
            } else if let module = ModuleRegistry.module(id: id) {
                ModulePlaceholderView(
                    title: module.title,
                    message: "The architecture for this module is connected. Its full workflow will be added in a later build.",
                    systemImage: module.systemImage
                )
            } else {
                Text("Module not found")
            }
        case .customTile(let id):
            CustomCollectionView(tileID: id)
        }
    }
}
