import SwiftUI
import SwiftData
import PhotosUI

struct EditJourneyMomentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let moment: JourneyMoment

    @Query(sort: \PhotoAsset.sortOrder) private var allPhotoAssets: [PhotoAsset]

    @State private var title: String
    @State private var momentDate: Date
    @State private var category: String
    @State private var summary: String
    @State private var reflection: String
    @State private var gradeLevel: String
    @State private var includeInExports: Bool
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var removedPhotoIDs: Set<UUID> = []
    @State private var selectedPhotoID: UUID?
    @State private var isSaving = false
    @State private var saveError: String?

    private let categories = ["General", "Academic", "Activity", "Athletics", "Award", "Experience", "Service", "Work", "Personal"]
    private let grades = ["", "9", "10", "11", "12"]

    init(moment: JourneyMoment) {
        self.moment = moment
        _title = State(initialValue: moment.title)
        _momentDate = State(initialValue: moment.momentDate)
        _category = State(initialValue: moment.category)
        _summary = State(initialValue: moment.summary)
        _reflection = State(initialValue: moment.reflection)
        _gradeLevel = State(initialValue: moment.gradeLevel)
        _includeInExports = State(initialValue: moment.includeInExports)
    }

    private var originalPhotos: [PhotoAsset] {
        allPhotoAssets
            .filter {
                $0.ownerType == PhotoOwnerType.journeyMoment &&
                $0.ownerID == moment.id
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var visibleExistingPhotos: [PhotoAsset] {
        originalPhotos.filter { !removedPhotoIDs.contains($0.id) }
    }

    private var availablePhotoSlots: Int {
        max(0, 6 - visibleExistingPhotos.count)
    }

    private var finalPhotoCount: Int {
        visibleExistingPhotos.count + selectedPhotos.count
    }

    var body: some View {
        Form {
            Section("Moment") {
                TextField("What happened?", text: $title)
                DatePicker("Date", selection: $momentDate, displayedComponents: .date)

                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0).tag($0) }
                }

                Picker("Grade", selection: $gradeLevel) {
                    Text("Not set").tag("")
                    ForEach(grades.filter { !$0.isEmpty }, id: \.self) {
                        Text("Grade \($0)").tag($0)
                    }
                }
            }

            Section {
                if !visibleExistingPhotos.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(visibleExistingPhotos) { photo in
                            VStack(spacing: 8) {
                                Button {
                                    selectedPhotoID = photo.id
                                } label: {
                                    StoredPhotoThumbnailView(
                                        filename: photo.thumbnailFilename,
                                        maxHeight: 360
                                    )
                                }
                                .buttonStyle(.plain)

                                Button(role: .destructive) {
                                    removedPhotoIDs.insert(photo.id)
                                } label: {
                                    Label("Remove Photo", systemImage: "trash")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }

                if availablePhotoSlots > 0 {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: availablePhotoSlots,
                        matching: .images
                    ) {
                        Label(
                            visibleExistingPhotos.isEmpty ? "Choose Photos" : "Add Replacement or More Photos",
                            systemImage: "photo.on.rectangle.angled"
                        )
                    }
                }

                if !selectedPhotos.isEmpty {
                    HStack {
                        Text("\(selectedPhotos.count) new photo\(selectedPhotos.count == 1 ? "" : "s") selected")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Clear") {
                            selectedPhotos = []
                        }
                        .font(.footnote)
                    }
                }

                if !removedPhotoIDs.isEmpty {
                    Button("Undo Removed Photos") {
                        removedPhotoIDs.removeAll()
                    }
                    .font(.footnote)
                }

                Text("\(finalPhotoCount) of 6 photos after saving")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Photos")
            } footer: {
                Text("Tap a saved photo to view it full screen. Remove it before choosing a replacement. Changes are not permanent until you tap Save.")
            }

            Section("What do you want to remember?") {
                TextField("Short description", text: $summary, axis: .vertical)
                    .lineLimit(3...6)

                TextField("Optional reflection", text: $reflection, axis: .vertical)
                    .lineLimit(4...10)
            }

            Section {
                Toggle("Available for future exports", isOn: $includeInExports)
            } footer: {
                Text("You will still choose what to share each time you create an export.")
            }

            if let saveError {
                Section {
                    Text(saveError)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Moment")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isSaving)
        .overlay {
            if isSaving {
                ProgressView("Saving...")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .disabled(
                    title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    finalPhotoCount > 6 ||
                    isSaving
                )
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges || isSaving)
        .fullScreenCover(
            isPresented: Binding(
                get: { selectedPhotoID != nil },
                set: { if !$0 { selectedPhotoID = nil } }
            )
        ) {
            if let selectedPhotoID {
                JourneyPhotoViewer(photos: visibleExistingPhotos, selectedPhotoID: selectedPhotoID)
            }
        }
    }

    private var hasUnsavedChanges: Bool {
        title != moment.title ||
        momentDate != moment.momentDate ||
        category != moment.category ||
        summary != moment.summary ||
        reflection != moment.reflection ||
        gradeLevel != moment.gradeLevel ||
        includeInExports != moment.includeInExports ||
        !selectedPhotos.isEmpty ||
        !removedPhotoIDs.isEmpty
    }

    @MainActor
    private func save() async {
        saveError = nil
        isSaving = true

        let removedPhotos = originalPhotos.filter { removedPhotoIDs.contains($0.id) }
        let removedPhotoFiles = removedPhotos.map { ($0.imageFilename, $0.thumbnailFilename) }
        let remainingPhotos = originalPhotos.filter { !removedPhotoIDs.contains($0.id) }
        var stagedPhotos: [PhotoAsset] = []

        do {
            for (offset, pickerItem) in selectedPhotos.enumerated() {
                let photoID = UUID()
                let stored = try await PhotoStorageService.savePickerItem(pickerItem, id: photoID)
                let photo = PhotoAsset(
                    ownerType: PhotoOwnerType.journeyMoment,
                    ownerID: moment.id,
                    imageFilename: stored.imageFilename,
                    thumbnailFilename: stored.thumbnailFilename,
                    sortOrder: remainingPhotos.count + offset
                )
                photo.id = photoID
                stagedPhotos.append(photo)
            }

            moment.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            moment.momentDate = momentDate
            moment.category = category
            moment.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            moment.reflection = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
            moment.gradeLevel = gradeLevel
            moment.includeInExports = includeInExports
            moment.updatedAt = Date()

            for (index, photo) in remainingPhotos.enumerated() {
                photo.sortOrder = index
                photo.updatedAt = Date()
            }

            for photo in removedPhotos {
                modelContext.delete(photo)
            }

            for photo in stagedPhotos {
                modelContext.insert(photo)
            }

            try modelContext.save()

            for files in removedPhotoFiles {
                PhotoStorageService.deleteFiles(
                    imageFilename: files.0,
                    thumbnailFilename: files.1
                )
            }

            isSaving = false
            dismiss()
        } catch {
            for photo in stagedPhotos {
                PhotoStorageService.deleteFiles(
                    imageFilename: photo.imageFilename,
                    thumbnailFilename: photo.thumbnailFilename
                )
            }
            modelContext.rollback()
            isSaving = false
            saveError = "Your changes were not saved. Please try again. \(error.localizedDescription)"
        }
    }
}
