import SwiftUI
import SwiftData

struct AddEditModuleRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let config: ModuleRecordConfig
    let record: ModuleRecord?

    @State private var title: String
    @State private var recordDate: Date
    @State private var category: String
    @State private var organization: String
    @State private var role: String
    @State private var details: String
    @State private var reflection: String
    @State private var status: String
    @State private var includeInExports: Bool
    @State private var showingSaveError = false
    @State private var didFinish = false
    @State private var draftOwnerID: UUID

    init(config: ModuleRecordConfig, record: ModuleRecord? = nil) {
        self.config = config
        self.record = record
        _title = State(initialValue: record?.title ?? "")
        _recordDate = State(initialValue: record?.recordDate ?? Date())
        _category = State(initialValue: record?.category ?? config.categories.first ?? "")
        _organization = State(initialValue: record?.organization ?? "")
        _role = State(initialValue: record?.role ?? "")
        _details = State(initialValue: record?.details ?? "")
        _reflection = State(initialValue: record?.reflection ?? "")
        _status = State(initialValue: record?.status ?? config.statuses.first ?? "")
        _includeInExports = State(initialValue: record?.includeInExports ?? true)
        _draftOwnerID = State(initialValue: record?.id ?? UUID())
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                TextField(config.titleLabel, text: $title)

                DatePicker(config.dateLabel, selection: $recordDate, displayedComponents: .date)

                if !config.categories.isEmpty {
                    Picker(config.typeLabel, selection: $category) {
                        ForEach(config.categories, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
            }

            if config.organizationLabel != nil || config.roleLabel != nil {
                Section(config.contextSectionTitle) {
                    if let label = config.organizationLabel {
                        TextField(label, text: $organization)
                    }
                    if let label = config.roleLabel {
                        TextField(label, text: $role)
                    }
                }
            }

            Section(config.detailsLabel) {
                TextEditor(text: $details)
                    .frame(minHeight: 100)
            }

            if let reflectionLabel = config.reflectionLabel {
                Section(reflectionLabel) {
                    TextEditor(text: $reflection)
                        .frame(minHeight: 90)
                }
            }

            if !config.statuses.isEmpty {
                Section(config.statusSectionTitle) {
                    Picker("Status", selection: $status) {
                        ForEach(config.statuses, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
            }

            Section {
                AttachmentCollectionView(
                    ownerType: AttachmentOwnerType.moduleRecord,
                    ownerID: draftOwnerID,
                    allowsPhotos: true,
                    allowsFiles: true
                )
            } header: {
                Text("Keepsakes")
            } footer: {
                Text("Add photos, certificates, programs, PDFs, or other files now. They will stay connected to this item when you save it.")
            }

            Section {
                Toggle("Include in future exports", isOn: $includeInExports)
            } footer: {
                Text("You can change this later when building a resume, activities list, or other export.")
            }
        }
        .navigationTitle(record == nil ? "Add \(config.singularTitle)" : "Edit \(config.singularTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { cancel() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(!canSave)
            }
        }
        .interactiveDismissDisabled(record == nil && !didFinish)
        .alert("Could Not Save", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your changes could not be saved. Please try again.")
        }
        .onDisappear {
            if record == nil && !didFinish {
                cleanupDraftAttachments()
            }
        }
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if let record {
            record.title = cleanTitle
            record.recordDate = recordDate
            record.category = category
            record.organization = organization.trimmingCharacters(in: .whitespacesAndNewlines)
            record.role = role.trimmingCharacters(in: .whitespacesAndNewlines)
            record.details = details.trimmingCharacters(in: .whitespacesAndNewlines)
            record.reflection = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
            record.status = status
            record.includeInExports = includeInExports
            record.updatedAt = Date()
        } else {
            let newRecord = ModuleRecord(
                moduleID: config.moduleID,
                title: cleanTitle,
                recordDate: recordDate,
                category: category,
                organization: organization.trimmingCharacters(in: .whitespacesAndNewlines),
                role: role.trimmingCharacters(in: .whitespacesAndNewlines),
                details: details.trimmingCharacters(in: .whitespacesAndNewlines),
                reflection: reflection.trimmingCharacters(in: .whitespacesAndNewlines),
                status: status,
                includeInExports: includeInExports
            )
            newRecord.id = draftOwnerID
            modelContext.insert(newRecord)
        }

        do {
            try modelContext.save()
            didFinish = true
            dismiss()
        } catch {
            modelContext.rollback()
            showingSaveError = true
        }
    }

    private func cancel() {
        if record == nil {
            cleanupDraftAttachments()
        }
        didFinish = true
        dismiss()
    }

    private func cleanupDraftAttachments() {
        let allPhotos = (try? modelContext.fetch(FetchDescriptor<PhotoAsset>())) ?? []
        let draftPhotos = allPhotos.filter {
            $0.ownerType == AttachmentOwnerType.moduleRecord && $0.ownerID == draftOwnerID
        }

        for photo in draftPhotos {
            PhotoStorageService.deleteFiles(
                imageFilename: photo.imageFilename,
                thumbnailFilename: photo.thumbnailFilename
            )
            modelContext.delete(photo)
        }

        FileAttachmentStorageService.deleteAll(
            ownerType: AttachmentOwnerType.moduleRecord,
            ownerID: draftOwnerID
        )

        try? modelContext.save()
    }
}
