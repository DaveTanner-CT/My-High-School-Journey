import SwiftUI
import SwiftData

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
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var didFinish = false
    @State private var draftOwnerID = UUID()

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
                AttachmentCollectionView(
                    ownerType: AttachmentOwnerType.journeyMoment,
                    ownerID: draftOwnerID,
                    allowsPhotos: true,
                    allowsFiles: true
                )
            } header: {
                Text("Keepsakes")
            } footer: {
                Text("Add photos, certificates, programs, PDFs, or other files now. They will stay connected to this Journey Moment when you save it.")
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
                Button("Cancel") { cancel() }
                    .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving
                    )
            }
        }
        .interactiveDismissDisabled(!didFinish)
        .onDisappear {
            if !didFinish {
                cleanupDraftAttachments()
            }
        }
    }

    private func save() {
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
        moment.id = draftOwnerID

        modelContext.insert(moment)

        do {
            try modelContext.save()
            didFinish = true
            isSaving = false
            dismiss()
        } catch {
            modelContext.rollback()
            isSaving = false
            saveError = "This moment was not saved. Please try again. \(error.localizedDescription)"
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
            $0.ownerType == AttachmentOwnerType.journeyMoment && $0.ownerID == draftOwnerID
        }

        for photo in draftPhotos {
            PhotoStorageService.deleteFiles(
                imageFilename: photo.imageFilename,
                thumbnailFilename: photo.thumbnailFilename
            )
            modelContext.delete(photo)
        }

        FileAttachmentStorageService.deleteAll(
            ownerType: AttachmentOwnerType.journeyMoment,
            ownerID: draftOwnerID
        )

        try? modelContext.save()
    }
}
