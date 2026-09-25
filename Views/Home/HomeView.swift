import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var profiles: [StudentProfile]
    @Query private var preferences: [TilePreference]
    @Query private var customTiles: [CustomTile]
    @Query(sort: \CustomTileItem.itemDate, order: .reverse) private var customItems: [CustomTileItem]
    @Query(sort: \JourneyMoment.momentDate, order: .reverse) private var moments: [JourneyMoment]
    @Query(sort: \ModuleRecord.recordDate, order: .reverse) private var moduleRecords: [ModuleRecord]
    @Query(sort: \PhotoAsset.sortOrder) private var photoAssets: [PhotoAsset]

    @State private var showingQuickAdd = false
    @AppStorage("homeTileDisplayMode") private var homeTileDisplayModeRaw = HomeTileDisplayMode.compact.rawValue

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

    private var displayMode: HomeTileDisplayMode {
        HomeTileDisplayMode(rawValue: homeTileDisplayModeRaw) ?? .compact
    }

    private var tileRows: [HomeTileRow] {
        switch displayMode {
        case .wide:
            return visibleEntries.map { .wide($0) }

        case .compact:
            var rows: [HomeTileRow] = []
            var pending: HomeTileEntry?

            for entry in visibleEntries {
                if let first = pending {
                    rows.append(.compact(first: first, second: entry))
                    pending = nil
                } else {
                    pending = entry
                }
            }

            if let pending {
                rows.append(.compact(first: pending, second: nil))
            }

            return rows
        }
    }

    var body: some View {
        let rows = tileRows

        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header
                quickAddButton

                if let latest = moments.first {
                    latestMomentCard(latest)
                } else {
                    startJourneyCard
                }

                VStack(spacing: 14) {
                    ForEach(0..<rows.count, id: \.self) { index in
                        tileRowView(rows[index])
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

            Text("Keep telling your story!")
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
    private func tileRowView(_ row: HomeTileRow) -> some View {
        switch row {
        case .wide(let entry):
            reorderableTile(for: entry)

        case .compact(let first, let second):
            HStack(alignment: .top, spacing: 14) {
                reorderableTile(for: first)
                    .frame(maxWidth: .infinity)

                if let second = second {
                    reorderableTile(for: second)
                        .frame(maxWidth: .infinity)
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func reorderableTile(for entry: HomeTileEntry) -> some View {
        tile(for: entry)
            .draggable(entry.id)
            .dropDestination(for: String.self) { droppedIDs, _ in
                guard let sourceID = droppedIDs.first else { return false }
                return moveTile(sourceID: sourceID, before: entry.id)
            }
            .accessibilityHint("Press and drag to rearrange this tile.")
    }

    @ViewBuilder
    private func tile(for entry: HomeTileEntry) -> some View {
        switch entry.kind {
        case .builtIn(let moduleID):
            if let module = ModuleRegistry.module(id: moduleID) {
                NavigationLink(value: AppRoute.module(module.id)) {
                    ModuleTileView(
                        module: module,
                        statusText: statusText(for: module),
                        displayMode: displayMode
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
                            itemCount: customItemCount(for: tile),
                            displayMode: displayMode
                        )
                    }
                    .buttonStyle(.plain)
                } else if tile.tileType == "shortcut", !tile.targetModuleID.isEmpty {
                    NavigationLink(value: AppRoute.module(tile.targetModuleID)) {
                        CustomTileCardView(
                            tile: tile,
                            itemCount: customItemCount(for: tile),
                            displayMode: displayMode
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(value: AppRoute.customTile(tile.id)) {
                        CustomTileCardView(
                            tile: tile,
                            itemCount: customItemCount(for: tile),
                            displayMode: displayMode
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

    private func statusText(for module: AppModule) -> String? {
        if module.id == "journey" {
            return journeyStatusText
        }

        guard ModuleRecordConfig.supportsRecords(module.id) else {
            return nil
        }

        let count = moduleRecords.filter { $0.moduleID == module.id }.count
        return count == 0 ? "Start here" : "\(count) saved"
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

    @discardableResult
    private func moveTile(sourceID: String, before targetID: String) -> Bool {
        guard sourceID != targetID else { return false }

        var reorderedVisible = visibleEntries
        guard let sourceIndex = reorderedVisible.firstIndex(where: { $0.id == sourceID }),
              let targetIndex = reorderedVisible.firstIndex(where: { $0.id == targetID }) else {
            return false
        }

        let moving = reorderedVisible.remove(at: sourceIndex)
        let insertionIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        reorderedVisible.insert(moving, at: max(0, insertionIndex))

        let allEntries = allTileEntries
        let visibleIDs = Set(reorderedVisible.map(\.id))
        var reorderedIterator = reorderedVisible.makeIterator()
        var merged: [HomeTileEntry] = []

        for entry in allEntries {
            if visibleIDs.contains(entry.id), let nextVisible = reorderedIterator.next() {
                merged.append(nextVisible)
            } else {
                merged.append(entry)
            }
        }

        for (index, entry) in merged.enumerated() {
            switch entry.kind {
            case .builtIn(let moduleID):
                if let preference = preferences.first(where: { $0.moduleID == moduleID }) {
                    preference.sortOrder = index
                    preference.updatedAt = Date()
                }
            case .custom(let tileID):
                if let tile = customTiles.first(where: { $0.id == tileID }) {
                    tile.sortOrder = index
                    tile.updatedAt = Date()
                }
            }
        }

        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }

    private var allTileEntries: [HomeTileEntry] {
        let builtIns = preferences.map {
            HomeTileEntry(
                id: "module:\($0.moduleID)",
                sortOrder: $0.sortOrder,
                kind: .builtIn(moduleID: $0.moduleID)
            )
        }

        let customs = customTiles.map {
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
