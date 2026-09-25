import SwiftUI
import SwiftData
import PhotosUI

struct AddJourneyMomentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var momentDate = Date()
    @State private var category = "General"
    @State private var summary = ""
    @State private var reflection = ""
    @State private var gradeLevel = ""
    @State private var includeInExports = true
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isSaving = false
    @State private var saveError: String?

    private let categories = ["General", "Academic", "Activity", "Athletics", "Award", "Experience", "Service", "Work", "Personal"]
    private let grades = ["", "9", "10", "11", "12"]

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
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 6,
                    matching: .images
                ) {
                    Label(
                        selectedPhotos.isEmpty ? "Add Photos" : "Change Photos",
                        systemImage: "photo.on.rectangle.angled"
                    )
                }

                if !selectedPhotos.isEmpty {
                    Text("\(selectedPhotos.count) photo\(selectedPhotos.count == 1 ? "" : "s") selected")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Photos")
            } footer: {
                Text("Photos stay with your private Journey and can be reused later in portfolios or selected exports.")
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
        .navigationTitle("New Moment")
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
                    title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving
                )
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges || isSaving)
    }

    private var hasUnsavedChanges: Bool {
        !title.isEmpty ||
        !summary.isEmpty ||
        !reflection.isEmpty ||
        category != "General" ||
        gradeLevel != "" ||
        !selectedPhotos.isEmpty
    }

    @MainActor
    private func save() async {
        saveError = nil
        isSaving = true

        let moment = JourneyMoment(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            momentDate: momentDate,
            category: category,
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            reflection: reflection.trimmingCharacters(in: .whitespacesAndNewlines),
            gradeLevel: gradeLevel,
            isFeatured: true,
            includeInExports: includeInExports
        )

        var stagedPhotos: [PhotoAsset] = []

        do {
            for (index, pickerItem) in selectedPhotos.enumerated() {
                let photoID = UUID()
                let stored = try await PhotoStorageService.savePickerItem(pickerItem, id: photoID)
                let photo = PhotoAsset(
                    ownerType: PhotoOwnerType.journeyMoment,
                    ownerID: moment.id,
                    imageFilename: stored.imageFilename,
                    thumbnailFilename: stored.thumbnailFilename,
                    sortOrder: index
                )
                photo.id = photoID
                stagedPhotos.append(photo)
            }

            modelContext.insert(moment)
            for photo in stagedPhotos {
                modelContext.insert(photo)
            }

            try modelContext.save()
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
            saveError = "This moment was not saved. Please try again. \(error.localizedDescription)"
        }
    }

}
