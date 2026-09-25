import SwiftUI
import SwiftData

struct HomeScreenSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [TilePreference]
    @Query private var customTiles: [CustomTile]
    @Query private var customTileItems: [CustomTileItem]

    @State private var showingAddTile = false
    @AppStorage("homeTileDisplayMode") private var homeTileDisplayModeRaw = HomeTileDisplayMode.compact.rawValue

    private var rows: [HomeTileEntry] {
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

    var body: some View {
        List {
            Section {
                Picker("Tile Size", selection: $homeTileDisplayModeRaw) {
                    ForEach(HomeTileDisplayMode.allCases) { mode in
                        Label(mode.title, systemImage: mode.systemImage)
                            .tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Home Layout")
            } footer: {
                Text("Compact shows two square tiles across. Wide shows one full-width tile per row. All Home tiles use the same size until you change this setting.")
            }

            Section {
                ForEach(rows) { row in
                    rowView(row)
                }
                .onMove(perform: moveRows)
            } header: {
                Text("Tiles")
            } footer: {
                Text("Turn tiles on or off and drag them into the order you want. You can also press and drag tiles directly on Home in either Compact or Wide view. Custom tiles can also be removed.")
            }

            Section {
                Button {
                    showingAddTile = true
                } label: {
                    Label("Add Custom Tile", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Home Screen")
        .toolbar { EditButton() }
        .sheet(isPresented: $showingAddTile) {
            NavigationStack {
                AddCustomTileView()
            }
        }
    }

    @ViewBuilder
    private func rowView(_ row: HomeTileEntry) -> some View {
        switch row.kind {
        case .builtIn(let moduleID):
            if let preference = preferences.first(where: { $0.moduleID == moduleID }),
               let module = ModuleRegistry.module(id: moduleID) {
                Toggle(isOn: enabledBinding(for: preference)) {
                    Label(module.title, systemImage: module.systemImage)
                }
            }

        case .custom(let tileID):
            if let tile = customTiles.first(where: { $0.id == tileID }) {
                Toggle(isOn: enabledBinding(for: tile)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Label(tile.title, systemImage: tile.systemImage)
                        Text("Custom tile")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        deleteCustomTile(tile)
                    }
                }
            }
        }
    }

    private func enabledBinding(for preference: TilePreference) -> Binding<Bool> {
        Binding(
            get: { preference.isEnabled },
            set: { newValue in
                preference.isEnabled = newValue
                preference.updatedAt = Date()
                try? modelContext.save()
            }
        )
    }

    private func enabledBinding(for tile: CustomTile) -> Binding<Bool> {
        Binding(
            get: { tile.isEnabled },
            set: { newValue in
                tile.isEnabled = newValue
                tile.updatedAt = Date()
                try? modelContext.save()
            }
        )
    }

    private func moveRows(from source: IndexSet, to destination: Int) {
        var reordered = rows
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, row) in reordered.enumerated() {
            switch row.kind {
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

        try? modelContext.save()
    }

    private func deleteCustomTile(_ tile: CustomTile) {
        for item in customTileItems where item.tileID == tile.id {
            modelContext.delete(item)
        }
        modelContext.delete(tile)
        try? modelContext.save()
    }
}
