import SwiftUI
import SwiftData

struct AddCustomTileItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let tileID: UUID
    let tileTitle: String

    @State private var title = ""
    @State private var notes = ""
    @State private var itemDate = Date()
    @State private var linkURL = ""
    @State private var draftOwnerID = UUID()
    @State private var didFinish = false

    var body: some View {
        Form {
            Section("Item") {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $itemDate, displayedComponents: .date)
            }

            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Link") {
                TextField("Optional web link", text: $linkURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
            }

            Section {
                AttachmentCollectionView(
                    ownerType: AttachmentOwnerType.customTileItem,
                    ownerID: draftOwnerID,
                    allowsPhotos: true,
                    allowsFiles: true
                )
            } header: {
                Text("Keepsakes")
            } footer: {
                Text("Add photos or files now. They will stay connected to this item when you save it.")
            }
        }
        .navigationTitle("Add to \(tileTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { cancel() }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveItem() }
                    .disabled(cleanTitle.isEmpty)
            }
        }
        .interactiveDismissDisabled(!didFinish)
        .onDisappear {
            if !didFinish {
                cleanupDraftAttachments()
            }
        }
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveItem() {
        let item = CustomTileItem(
            tileID: tileID,
            title: cleanTitle,
            itemDate: itemDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            linkURL: linkURL.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        item.id = draftOwnerID

        modelContext.insert(item)

        do {
            try modelContext.save()
            didFinish = true
            dismiss()
        } catch {
            modelContext.rollback()
        }
    }

    private func cancel() {
        cleanupDraftAttachments()
        didFinish = true
        dismiss()
    }

    private func cleanupDraftAttachments() {
        let allPhotos = (try? modelContext.fetch(FetchDescriptor<PhotoAsset>())) ?? []
        let draftPhotos = allPhotos.filter {
            $0.ownerType == AttachmentOwnerType.customTileItem && $0.ownerID == draftOwnerID
        }

        for photo in draftPhotos {
            PhotoStorageService.deleteFiles(
                imageFilename: photo.imageFilename,
                thumbnailFilename: photo.thumbnailFilename
            )
            modelContext.delete(photo)
        }

        FileAttachmentStorageService.deleteAll(
            ownerType: AttachmentOwnerType.customTileItem,
            ownerID: draftOwnerID
        )

        try? modelContext.save()
    }
}
