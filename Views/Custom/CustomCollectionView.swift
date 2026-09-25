import SwiftUI
import SwiftData

struct CustomCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tiles: [CustomTile]
    @Query(sort: \CustomTileItem.itemDate, order: .reverse) private var allItems: [CustomTileItem]

    let tileID: UUID

    @State private var showingAdd = false

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
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.headline)

                            Text(item.itemDate, format: .dateTime.month(.abbreviated).day().year())
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !item.notes.isEmpty {
                                Text(item.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let url = URL(string: item.linkURL), !item.linkURL.isEmpty {
                                Link(destination: url) {
                                    Label("Open Link", systemImage: "arrow.up.right.square")
                                        .font(.caption.weight(.semibold))
                                }
                                .padding(.top, 2)
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
                    .accessibilityLabel("Add Item")
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                AddCustomTileItemView(
                    tileID: tileID,
                    tileTitle: tile?.title ?? "My Collection"
                )
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
        try? modelContext.save()
    }
}
