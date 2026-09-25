import SwiftUI
import SwiftData

struct ModuleRecordsView: View {
    let moduleID: String

    @Query(sort: \ModuleRecord.recordDate, order: .reverse) private var allRecords: [ModuleRecord]
    @State private var showingAdd = false

    private var config: ModuleRecordConfig? {
        ModuleRecordConfig.config(for: moduleID)
    }

    private var records: [ModuleRecord] {
        allRecords.filter { $0.moduleID == moduleID }
    }

    var body: some View {
        Group {
            if let config {
                if records.isEmpty {
                    ContentUnavailableView {
                        Label("No \(config.title) Yet", systemImage: config.systemImage)
                    } description: {
                        Text(emptyMessage(for: config))
                    } actions: {
                        Button("Add \(config.singularTitle)") {
                            showingAdd = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        Section {
                            ForEach(records) { record in
                                NavigationLink {
                                    ModuleRecordDetailView(record: record, config: config)
                                } label: {
                                    ModuleRecordRow(record: record, config: config)
                                }
                            }
                        } header: {
                            Text("\(records.count) saved")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            } else {
                ContentUnavailableView("Module unavailable", systemImage: "questionmark.folder")
            }
        }
        .navigationTitle(config?.title ?? "Records")
        .toolbar {
            if config != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            if let config {
                NavigationStack {
                    AddEditModuleRecordView(config: config)
                }
            }
        }
    }

    private func emptyMessage(for config: ModuleRecordConfig) -> String {
        switch config.moduleID {
        case "activities":
            return "Keep track of clubs, leadership, arts, and other things you take part in."
        case "athletics":
            return "Save teams, seasons, stats, milestones, and the moments you want to remember."
        case "honors":
            return "Save awards and recognition now so you do not have to remember them later."
        case "experiences":
            return "Save jobs, service, internships, programs, and projects as they happen."
        case "people":
            return "Keep track of teachers, coaches, counselors, mentors, and others who know your work and growth."
        case "goals":
            return "Write down something you want to work toward and keep track of your progress."
        case "collegeVisits":
            return "Save campus visits, virtual visits, people you met, photos, and the impressions you want to remember later."
        case "recruiting":
            return "Keep coach contacts, questionnaires, visits, camps, offers, and your next steps together in one place."
        default:
            return "Add your first item."
        }
    }
}

private struct ModuleRecordRow: View {
    let record: ModuleRecord
    let config: ModuleRecordConfig

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: config.systemImage)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.headline)

                HStack(spacing: 6) {
                    if !record.category.isEmpty {
                        Text(record.category)
                    }
                    if !record.category.isEmpty {
                        Text("•")
                    }
                    Text(record.recordDate, format: .dateTime.month(.abbreviated).day().year())
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if !record.organization.isEmpty {
                    Text(record.organization)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if !record.status.isEmpty {
                    Text(record.status)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.primary.opacity(0.06), in: Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}
