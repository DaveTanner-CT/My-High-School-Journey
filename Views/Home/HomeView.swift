import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [StudentProfile]
    @Query private var preferences: [TilePreference]
    @Query private var customTiles: [CustomTile]
    @Query(sort: \CustomTileItem.itemDate, order: .reverse) private var customItems: [CustomTileItem]
    @Query(sort: \JourneyMoment.momentDate, order: .reverse) private var moments: [JourneyMoment]
    @Query(sort: \PhotoAsset.sortOrder) private var photoAssets: [PhotoAsset]

    @State private var showingQuickAdd = false

    private var preferredName: String {
        let trimmed = profiles.first?.preferredName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "there" : trimmed
    }

    private var graduationYear: Int? {
        profiles.first?.graduationYear
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

    private var tileRows: [HomeTileRow] {
        var rows: [HomeTileRow] = []
        var pendingCompact: HomeTileEntry?

        for entry in visibleEntries {
            if isWide(entry) {
                if let first = pendingCompact {
                    rows.append(.compact(first: first, second: nil))
                    pendingCompact = nil
                }
                rows.append(.wide(entry))
            } else if let first = pendingCompact {
                rows.append(.compact(first: first, second: entry))
                pendingCompact = nil
            } else {
                pendingCompact = entry
            }
        }

        if let pendingCompact {
            rows.append(.compact(first: pendingCompact, second: nil))
        }

        return rows
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header
                quickAddButton

                if let latest = moments.first {
                    latestMomentCard(latest)
                } else {
                    startJourneyCard
                }

                VStack(spacing: 14) {
                    ForEach(tileRows.indices, id: \.self) { index in
                        switch tileRows[index] {
                        case .wide(let entry):
                            tile(for: entry)

                        case .compact(let first, let second):
                            HStack(alignment: .stretch, spacing: 14) {
                                tile(for: first)
                                    .frame(maxWidth: .infinity)

                                if let second {
                                    tile(for: second)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 32)
        }
        .navigationTitle("High School Journey")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingQuickAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Quick Add")
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddView()
        }
        .navigationDestination(for: AppRoute.self) { route in
            AppRouteDestinationView(route: route)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hi, \(preferredName)")
                .font(.largeTitle.bold())

            HStack(spacing: 8) {
                if let graduationYear {
                    Text("Class of \(String(graduationYear))")
                }

                if graduationYear != nil && !moments.isEmpty {
                    Text("•")
                }

                if !moments.isEmpty {
                    Text("\(moments.count) \(moments.count == 1 ? "moment" : "moments") saved")
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)

            Text("Keep building the story you'll want later.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    private var quickAddButton: some View {
        Button {
            showingQuickAdd = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.headline)
                    .frame(width: 34, height: 34)
                    .background(.primary.opacity(0.08), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Add")
                        .font(.headline)
                    Text("Save something while it's fresh")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func latestMomentCard(_ moment: JourneyMoment) -> some View {
        NavigationLink {
            JourneyMomentDetailView(moment: moment)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Label("Latest from My Journey", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                if let photo = photos(for: moment).first {
                    StoredPhotoThumbnailView(
                        filename: photo.thumbnailFilename,
                        maxHeight: 360,
                        cornerRadius: 18
                    )
                }

                Text(moment.title)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                if !moment.summary.isEmpty {
                    Text(moment.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                HStack {
                    Text(moment.momentDate, format: .dateTime.month(.abbreviated).day().year())
                    Spacer()
                    Text("Open")
                    Image(systemName: "chevron.right")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var startJourneyCard: some View {
        Button {
            showingQuickAdd = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Label("Your Journey starts here", systemImage: "sparkles")
                    .font(.headline)

                Text("Save a moment, photo, accomplishment, or experience you'll want to remember later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Add my first moment →")
                    .font(.subheadline.weight(.semibold))
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
                    ModuleTileView(
                        module: module,
                        statusText: module.id == "journey" ? journeyStatusText : nil
                    )
                }
                .buttonStyle(.plain)
            }

        case .custom(let tileID):
            if let tile = customTiles.first(where: { $0.id == tileID }) {
                if tile.tileType == "resource", let url = URL(string: tile.resourceURL), !tile.resourceURL.isEmpty {
                    Link(destination: url) {
                        CustomTileCardView(
                            tile: tile,
                            itemCount: customItemCount(for: tile)
                        )
                    }
                    .buttonStyle(.plain)
                } else if tile.tileType == "shortcut", !tile.targetModuleID.isEmpty {
                    NavigationLink(value: AppRoute.module(tile.targetModuleID)) {
                        CustomTileCardView(
                            tile: tile,
                            itemCount: customItemCount(for: tile)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(value: AppRoute.customTile(tile.id)) {
                        CustomTileCardView(
                            tile: tile,
                            itemCount: customItemCount(for: tile)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var journeyStatusText: String {
        if moments.isEmpty { return "Start my story" }
        return "\(moments.count) \(moments.count == 1 ? "moment" : "moments")"
    }

    private func photos(for moment: JourneyMoment) -> [PhotoAsset] {
        photoAssets
            .filter {
                $0.ownerType == PhotoOwnerType.journeyMoment && $0.ownerID == moment.id
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private func customItemCount(for tile: CustomTile) -> Int? {
        guard tile.tileType == "collection" else { return nil }
        return customItems.filter { $0.tileID == tile.id }.count
    }

    private func isWide(_ entry: HomeTileEntry) -> Bool {
        switch entry.kind {
        case .builtIn(let moduleID):
            return ModuleRegistry.module(id: moduleID)?.tileSize == .wide
        case .custom(let tileID):
            return customTiles.first(where: { $0.id == tileID })?.isWide ?? false
        }
    }

}

private enum HomeTileRow: Identifiable {
    case wide(HomeTileEntry)
    case compact(first: HomeTileEntry, second: HomeTileEntry?)

    var id: String {
        switch self {
        case .wide(let entry):
            return "wide:\(entry.id)"
        case .compact(let first, let second):
            return "compact:\(first.id):\(second?.id ?? "empty")"
        }
    }
}
