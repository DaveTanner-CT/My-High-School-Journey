import SwiftUI
import SwiftData

struct CustomCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tiles: [CustomTile]
    @Query(sort: \CustomTileItem.itemDate, order: .reverse) private var allItems: [CustomTileItem]

    let tileID: UUID

    @State private var showingAdd = false
    @State private var title = ""
    @State private var notes = ""
    @State private var itemDate = Date()

    private var tile: CustomTile? { tiles.first { $0.id == tileID } }
    private var items: [CustomTileItem] { allItems.filter { $0.tileID == tileID } }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView {
                    Label("Nothing here yet", systemImage: tile?.systemImage ?? "square.grid.2x2")
                } description: {
                    Text("Add the first item to this custom collection.")
                } actions: {
                    Button("Add Item") { showingAdd = true }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text(item.itemDate, format: .dateTime.month(.abbreviated).day().year())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !item.notes.isEmpty {
                                Text(item.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle(tile?.title ?? "My Tile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                Form {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $itemDate, displayedComponents: .date)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
                .navigationTitle("New Item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { resetAndDismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveItem() }
                            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private func saveItem() {
        modelContext.insert(CustomTileItem(
            tileID: tileID,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            itemDate: itemDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
        try? modelContext.save()
        resetAndDismiss()
    }

    private func resetAndDismiss() {
        title = ""
        notes = ""
        itemDate = Date()
        showingAdd = false
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(items[index]) }
        try? modelContext.save()
    }
}
