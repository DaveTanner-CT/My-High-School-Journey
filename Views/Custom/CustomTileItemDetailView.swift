import SwiftUI
import SwiftData

struct CustomTileItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let item: CustomTileItem
    let tileTitle: String

    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 7) {
                    Text(item.title)
                        .font(.title2.bold())
                    Text(item.itemDate, format: .dateTime.month(.abbreviated).day().year())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if !item.notes.isEmpty {
                Section("Notes") {
                    Text(item.notes)
                }
            }

            if let url = URL(string: item.linkURL), !item.linkURL.isEmpty {
                Section("Link") {
                    Link(destination: url) {
                        Label("Open Link", systemImage: "arrow.up.right.square")
                    }
                }
            }

            Section {
                AttachmentCollectionView(
                    ownerType: AttachmentOwnerType.customTileItem,
                    ownerID: item.id,
                    allowsPhotos: true,
                    allowsFiles: true
                )
            } header: {
                Text("Keepsakes")
            } footer: {
                Text("Add photos or files that belong with this item.")
            }

            Section {
                Button("Delete Item", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle(tileTitle)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this item?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("The item and its saved photos and files will be removed.")
        }
    }

    private func deleteItem() {
        let ownerID = item.id
        let relatedPhotos = (try? modelContext.fetch(FetchDescriptor<PhotoAsset>())) ?? []
        let ownedPhotos = relatedPhotos.filter {
            $0.ownerType == AttachmentOwnerType.customTileItem && $0.ownerID == ownerID
        }

        for photo in ownedPhotos {
            PhotoStorageService.deleteFiles(
                imageFilename: photo.imageFilename,
                thumbnailFilename: photo.thumbnailFilename
            )
            modelContext.delete(photo)
        }
        FileAttachmentStorageService.deleteAll(
            ownerType: AttachmentOwnerType.customTileItem,
            ownerID: ownerID
        )

        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}
