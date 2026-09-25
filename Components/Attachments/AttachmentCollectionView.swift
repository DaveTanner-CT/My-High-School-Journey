import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
import QuickLook

struct AttachmentCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PhotoAsset.sortOrder) private var allPhotoAssets: [PhotoAsset]

    let ownerType: String
    let ownerID: UUID
    var allowsPhotos: Bool = true
    var allowsFiles: Bool = true

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var files: [StoredFileAttachment] = []
    @State private var showingFileImporter = false
    @State private var previewURL: URL?
    @State private var isSavingPhotos = false
    @State private var errorMessage: String?

    private var photos: [PhotoAsset] {
        allPhotoAssets
            .filter { $0.ownerType == ownerType && $0.ownerID == ownerID }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if allowsPhotos, !photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(photos) { photo in
                            VStack(spacing: 6) {
                                StoredPhotoThumbnailView(
                                    filename: photo.thumbnailFilename,
                                    maxHeight: 120,
                                    cornerRadius: 12
                                )
                                .frame(width: 150)

                                Button(role: .destructive) {
                                    deletePhoto(photo)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }

            if allowsFiles, !files.isEmpty {
                VStack(spacing: 8) {
                    ForEach(files) { file in
                        HStack(spacing: 10) {
                            Image(systemName: "doc.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            Button {
                                previewURL = FileAttachmentStorageService.fileURL(for: file)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(file.displayName)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    if file.byteCount > 0 {
                                        Text(ByteCountFormatter.string(fromByteCount: file.byteCount, countStyle: .file))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Button(role: .destructive) {
                                deleteFile(file)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .accessibilityLabel("Remove \(file.displayName)")
                        }
                        .padding(.vertical, 3)
                    }
                }
            }

            HStack(spacing: 10) {
                if allowsPhotos {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 6,
                        matching: .images
                    ) {
                        Label("Add Photo", systemImage: "photo.badge.plus")
                    }
                    .buttonStyle(.bordered)
                }

                if allowsFiles {
                    Button {
                        showingFileImporter = true
                    } label: {
                        Label("Add File", systemImage: "doc.badge.plus")
                    }
                    .buttonStyle(.bordered)
                }
            }

            if !selectedPhotos.isEmpty {
                Button {
                    Task { await saveSelectedPhotos() }
                } label: {
                    if isSavingPhotos {
                        ProgressView()
                    } else {
                        Text("Save \(selectedPhotos.count) Selected Photo\(selectedPhotos.count == 1 ? "" : "s")")
                    }
                }
                .disabled(isSavingPhotos)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            reloadFiles()
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                do {
                    _ = try FileAttachmentStorageService.importFiles(
                        urls,
                        ownerType: ownerType,
                        ownerID: ownerID
                    )
                    reloadFiles()
                    errorMessage = nil
                } catch {
                    errorMessage = error.localizedDescription
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .sheet(
            isPresented: Binding(
                get: { previewURL != nil },
                set: { if !$0 { previewURL = nil } }
            )
        ) {
            if let previewURL {
                QuickLookPreview(url: previewURL)
            }
        }
    }

    @MainActor
    private func saveSelectedPhotos() async {
        guard !selectedPhotos.isEmpty else { return }
        isSavingPhotos = true
        errorMessage = nil
        var staged: [PhotoAsset] = []

        do {
            let startOrder = photos.count
            for (offset, item) in selectedPhotos.enumerated() {
                let photoID = UUID()
                let stored = try await PhotoStorageService.savePickerItem(item, id: photoID)
                let photo = PhotoAsset(
                    ownerType: ownerType,
                    ownerID: ownerID,
                    imageFilename: stored.imageFilename,
                    thumbnailFilename: stored.thumbnailFilename,
                    sortOrder: startOrder + offset
                )
                photo.id = photoID
                staged.append(photo)
                modelContext.insert(photo)
            }

            try modelContext.save()
            selectedPhotos = []
            isSavingPhotos = false
        } catch {
            for photo in staged {
                PhotoStorageService.deleteFiles(
                    imageFilename: photo.imageFilename,
                    thumbnailFilename: photo.thumbnailFilename
                )
            }
            modelContext.rollback()
            isSavingPhotos = false
            errorMessage = "The selected photo could not be saved. \(error.localizedDescription)"
        }
    }

    private func deletePhoto(_ photo: PhotoAsset) {
        let imageFilename = photo.imageFilename
        let thumbnailFilename = photo.thumbnailFilename
        modelContext.delete(photo)
        do {
            try modelContext.save()
            PhotoStorageService.deleteFiles(
                imageFilename: imageFilename,
                thumbnailFilename: thumbnailFilename
            )
        } catch {
            modelContext.rollback()
            errorMessage = "The photo could not be removed."
        }
    }

    private func deleteFile(_ file: StoredFileAttachment) {
        do {
            try FileAttachmentStorageService.delete(file)
            reloadFiles()
            errorMessage = nil
        } catch {
            errorMessage = "The file could not be removed. \(error.localizedDescription)"
        }
    }

    private func reloadFiles() {
        files = FileAttachmentStorageService.attachments(ownerType: ownerType, ownerID: ownerID)
    }
}

private struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.url = url
        uiViewController.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}
