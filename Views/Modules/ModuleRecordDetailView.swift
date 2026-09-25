import SwiftUI
import SwiftData

struct ModuleRecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let record: ModuleRecord
    let config: ModuleRecordConfig

    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.title)
                        .font(.title2.bold())

                    HStack(spacing: 8) {
                        if !record.category.isEmpty {
                            Label(record.category, systemImage: config.systemImage)
                        }
                        Text(record.recordDate, format: .dateTime.month(.abbreviated).day().year())
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if !record.organization.isEmpty || !record.role.isEmpty {
                Section("Where & How") {
                    if !record.organization.isEmpty {
                        LabeledContent(config.organizationLabel ?? "Organization", value: record.organization)
                    }
                    if !record.role.isEmpty {
                        LabeledContent(config.roleLabel ?? "Role", value: record.role)
                    }
                }
            }

            if !record.details.isEmpty {
                Section(config.detailsLabel) {
                    Text(record.details)
                }
            }

            if !record.reflection.isEmpty, let reflectionLabel = config.reflectionLabel {
                Section(reflectionLabel) {
                    Text(record.reflection)
                }
            }

            if !record.status.isEmpty {
                Section("Progress") {
                    LabeledContent("Status", value: record.status)
                }
            }

            Section("Future Use") {
                LabeledContent("Include in exports", value: record.includeInExports ? "Yes" : "No")
            }

            Section {
                Button("Delete \(config.singularTitle)", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle(config.singularTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                AddEditModuleRecordView(config: config, record: record)
            }
        }
        .confirmationDialog(
            "Delete this \(config.singularTitle.lowercased())?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteRecord()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func deleteRecord() {
        modelContext.delete(record)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
        }
    }
}
