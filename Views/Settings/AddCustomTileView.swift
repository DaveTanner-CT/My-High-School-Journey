import SwiftUI
import SwiftData

struct AddCustomTileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [TilePreference]
    @Query private var existingTiles: [CustomTile]

    @State private var title = ""
    @State private var systemImage = "square.grid.2x2.fill"
    @State private var tileType = "collection"
    @State private var resourceURL = ""
    @State private var targetModuleID = "journey"
    @State private var isWide = false

    private let iconChoices = [
        "square.grid.2x2.fill", "theatermasks.fill", "music.note", "paintpalette.fill",
        "book.fill", "camera.fill", "trophy.fill", "star.fill", "lightbulb.fill",
        "hammer.fill", "laptopcomputer", "globe.americas.fill"
    ]

    var body: some View {
        Form {
            Section("Tile") {
                TextField("Tile name", text: $title)

                Picker("Icon", selection: $systemImage) {
                    ForEach(iconChoices, id: \.self) { icon in
                        Label(icon.replacingOccurrences(of: ".fill", with: ""), systemImage: icon)
                            .tag(icon)
                    }
                }

                Toggle("Wide tile", isOn: $isWide)
            }

            Section("Type") {
                Picker("Tile type", selection: $tileType) {
                    Text("Collection").tag("collection")
                    Text("Shortcut").tag("shortcut")
                    Text("Resource").tag("resource")
                }
                .pickerStyle(.segmented)

                if tileType == "resource" {
                    TextField("https://…", text: $resourceURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                if tileType == "shortcut" {
                    Picker("Open", selection: $targetModuleID) {
                        ForEach(ModuleRegistry.modules) { module in
                            Text(module.title).tag(module.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Custom Tile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { addTile() }
                    .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if tileType == "resource" {
            guard let url = URL(string: resourceURL), let scheme = url.scheme?.lowercased() else { return false }
            return scheme == "https" || scheme == "http"
        }
        return true
    }

    private func addTile() {
        let highestBuiltInOrder = preferences.map(\.sortOrder).max() ?? -1
        let highestCustomOrder = existingTiles.map(\.sortOrder).max() ?? -1
        let nextOrder = max(highestBuiltInOrder, highestCustomOrder) + 1

        let tile = CustomTile(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            systemImage: systemImage,
            tileType: tileType,
            resourceURL: tileType == "resource" ? resourceURL.trimmingCharacters(in: .whitespacesAndNewlines) : "",
            targetModuleID: tileType == "shortcut" ? targetModuleID : "",
            isEnabled: true,
            isWide: isWide,
            sortOrder: nextOrder
        )
        modelContext.insert(tile)
        try? modelContext.save()
        dismiss()
    }
}
