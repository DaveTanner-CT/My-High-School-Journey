import SwiftUI
import SwiftData

struct HomeTileReorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var preferences: [TilePreference]
    @Query private var customTiles: [CustomTile]

    @State private var editMode: EditMode = .active

    private var visibleEntries: [HomeTileEntry] {
        allEntries.filter { entry in
            switch entry.kind {
            case .builtIn(let moduleID):
                return preferences.first(where: { $0.moduleID == moduleID })?.isEnabled == true
            case .custom(let tileID):
                return customTiles.first(where: { $0.id == tileID })?.isEnabled == true
            }
        }
    }

    private var allEntries: [HomeTileEntry] {
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
        NavigationStack {
            List {
                Section {
                    ForEach(visibleEntries) { entry in
                        row(for: entry)
                    }
                    .onMove(perform: moveVisibleEntries)
                } footer: {
                    Text("Drag the handles to put your Home tiles in the order you want. This works the same for Compact and Wide layouts.")
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Reorder Tiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func row(for entry: HomeTileEntry) -> some View {
        switch entry.kind {
        case .builtIn(let moduleID):
            if let module = ModuleRegistry.module(id: moduleID) {
                Label(module.title, systemImage: module.systemImage)
            }
        case .custom(let tileID):
            if let tile = customTiles.first(where: { $0.id == tileID }) {
                VStack(alignment: .leading, spacing: 2) {
                    Label(tile.title, systemImage: tile.systemImage)
                    Text("Custom tile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func moveVisibleEntries(from source: IndexSet, to destination: Int) {
        var reorderedVisible = visibleEntries
        reorderedVisible.move(fromOffsets: source, toOffset: destination)

        let visibleIDs = Set(reorderedVisible.map(\.id))
        var iterator = reorderedVisible.makeIterator()
        var merged: [HomeTileEntry] = []

        for entry in allEntries {
            if visibleIDs.contains(entry.id), let nextVisible = iterator.next() {
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

        try? modelContext.save()
    }
}
