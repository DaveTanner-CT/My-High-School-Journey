import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \JourneyMoment.momentDate, order: .reverse) private var moments: [JourneyMoment]
    @Query(sort: \CustomTileItem.itemDate, order: .reverse) private var customItems: [CustomTileItem]
    @Query(sort: \ModuleRecord.recordDate, order: .reverse) private var moduleRecords: [ModuleRecord]
    @Query private var customTiles: [CustomTile]
    @Query private var preferences: [TilePreference]

    @State private var searchText = ""

    private var normalizedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingMoments: [JourneyMoment] {
        guard !normalizedQuery.isEmpty else { return [] }
        return moments.filter { moment in
            [moment.title, moment.category, moment.summary, moment.reflection, moment.gradeLevel]
                .contains { $0.localizedCaseInsensitiveContains(normalizedQuery) }
        }
    }


    private var matchingModuleRecords: [ModuleRecord] {
        guard !normalizedQuery.isEmpty else { return [] }
        return moduleRecords.filter { record in
            enabledModuleIDs.contains(record.moduleID) &&
            ModuleRecordConfig.supportsRecords(record.moduleID) &&
            [record.title, record.category, record.organization, record.role, record.details, record.reflection, record.status]
                .contains { $0.localizedCaseInsensitiveContains(normalizedQuery) }
        }
    }

    private var matchingCustomItems: [CustomTileItem] {
        guard !normalizedQuery.isEmpty else { return [] }
        let enabledTileIDs = Set(customTiles.filter(\.isEnabled).map(\.id))
        return customItems.filter { item in
            enabledTileIDs.contains(item.tileID) &&
            [item.title, item.notes, item.linkURL]
                .contains { $0.localizedCaseInsensitiveContains(normalizedQuery) }
        }
    }

    private var enabledModuleIDs: Set<String> {
        Set(preferences.filter(\.isEnabled).map(\.moduleID))
    }

    private var matchingModules: [AppModule] {
        guard !normalizedQuery.isEmpty else { return [] }
        return ModuleRegistry.modules.filter { module in
            enabledModuleIDs.contains(module.id) &&
            (module.title.localizedCaseInsensitiveContains(normalizedQuery) ||
             module.subtitle.localizedCaseInsensitiveContains(normalizedQuery))
        }
    }

    private var matchingCustomTiles: [CustomTile] {
        guard !normalizedQuery.isEmpty else { return [] }
        return customTiles.filter { tile in
            tile.isEnabled && tile.title.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    private var hasResults: Bool {
        !matchingMoments.isEmpty ||
        !matchingModuleRecords.isEmpty ||
        !matchingCustomItems.isEmpty ||
        !matchingModules.isEmpty ||
        !matchingCustomTiles.isEmpty
    }

    var body: some View {
        Group {
            if normalizedQuery.isEmpty {
                ContentUnavailableView {
                    Label("Search My Journey", systemImage: "magnifyingglass")
                } description: {
                    Text("Find Journey moments, activities, athletics, honors, experiences, people, goals, custom collections, and enabled parts of the app.")
                }
            } else if !hasResults {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("Nothing in your Journey matches \"\(normalizedQuery)\" yet.")
                }
            } else {
                List {
                    if !matchingMoments.isEmpty {
                        Section("Journey Moments") {
                            ForEach(matchingMoments) { moment in
                                NavigationLink {
                                    JourneyMomentDetailView(moment: moment)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(moment.title)
                                            .font(.headline)
                                        Text(moment.momentDate, format: .dateTime.month(.abbreviated).day().year())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        if !moment.summary.isEmpty {
                                            Text(moment.summary)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                    .padding(.vertical, 3)
                                }
                            }
                        }
                    }


                    if !matchingModuleRecords.isEmpty {
                        Section("Journey Records") {
                            ForEach(matchingModuleRecords) { record in
                                if let config = ModuleRecordConfig.config(for: record.moduleID) {
                                    NavigationLink {
                                        ModuleRecordDetailView(record: record, config: config)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(record.title)
                                                .font(.headline)
                                            Text(config.title)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            if !record.details.isEmpty {
                                                Text(record.details)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding(.vertical, 3)
                                    }
                                }
                            }
                        }
                    }

                    if !matchingCustomItems.isEmpty {
                        Section("Custom Collections") {
                            ForEach(matchingCustomItems) { item in
                                if let tile = customTiles.first(where: { $0.id == item.tileID }) {
                                    NavigationLink(value: AppRoute.customTile(tile.id)) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.title)
                                                .font(.headline)
                                            Text(tile.title)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            if !item.notes.isEmpty {
                                                Text(item.notes)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding(.vertical, 3)
                                    }
                                }
                            }
                        }
                    }

                    if !matchingModules.isEmpty || !matchingCustomTiles.isEmpty {
                        Section("App") {
                            ForEach(matchingModules) { module in
                                NavigationLink(value: AppRoute.module(module.id)) {
                                    Label {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(module.title)
                                            Text(module.subtitle)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    } icon: {
                                        Image(systemName: module.systemImage)
                                    }
                                }
                            }

                            ForEach(matchingCustomTiles) { tile in
                                if tile.tileType == "resource",
                                   let url = URL(string: tile.resourceURL),
                                   !tile.resourceURL.isEmpty {
                                    Link(destination: url) {
                                        Label(tile.title, systemImage: tile.systemImage)
                                    }
                                } else if tile.tileType == "shortcut", !tile.targetModuleID.isEmpty {
                                    NavigationLink(value: AppRoute.module(tile.targetModuleID)) {
                                        Label(tile.title, systemImage: tile.systemImage)
                                    }
                                } else {
                                    NavigationLink(value: AppRoute.customTile(tile.id)) {
                                        Label(tile.title, systemImage: tile.systemImage)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Search my Journey")
        .navigationDestination(for: AppRoute.self) { route in
            AppRouteDestinationView(route: route)
        }
    }
}
