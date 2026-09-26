import SwiftUI
import SwiftData
import UIKit

struct ResumeBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [StudentProfile]
    @Query(sort: \ModuleRecord.recordDate, order: .reverse) private var records: [ModuleRecord]

    @AppStorage("resumeFullName") private var fullName = ""
    @AppStorage("resumeEmail") private var email = ""
    @AppStorage("resumePhone") private var phone = ""
    @AppStorage("resumeLocation") private var location = ""
    @AppStorage("resumeIncludeHeadshot") private var includeHeadshot = true
    @AppStorage("profileHeadshotImageFilename") private var headshotImageFilename = ""
    @AppStorage("profileHeadshotThumbnailFilename") private var headshotThumbnailFilename = ""

    @State private var exportURL: URL?
    @State private var googleDocURL: URL?
    @State private var exportError: String?
    @State private var isCreatingPDF = false
    @State private var isCreatingGoogleDoc = false

    private let sectionOrder = ["experiences", "activities", "athletics", "honors"]

    private var profile: StudentProfile? { profiles.first }

    private var eligibleRecords: [ModuleRecord] {
        records.filter { sectionOrder.contains($0.moduleID) }
    }

    private var includedRecords: [ModuleRecord] {
        eligibleRecords.filter(\.includeInExports)
    }

    var body: some View {
        Form {
            Section {
                HStack(alignment: .top, spacing: 14) {
                    if !headshotThumbnailFilename.isEmpty {
                        ProfileHeadshotView(
                            thumbnailFilename: headshotThumbnailFilename,
                            size: 72
                        )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName)
                            .font(.title3.bold())

                        if let profile {
                            if !profile.schoolName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(profile.schoolName)
                                    .foregroundStyle(.secondary)
                            }
                            Text("Class of \(profile.graduationYear, format: .number.grouping(.never))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Resume Preview")
            } footer: {
                Text("Your resume pulls from the parts of your Journey you choose below. Nothing is shared unless you export it.")
            }

            Section("Contact Information") {
                TextField("Full name", text: $fullName)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                TextField("City, State", text: $location)
                    .textContentType(.addressCityAndState)

                if !headshotThumbnailFilename.isEmpty {
                    Toggle("Include headshot", isOn: $includeHeadshot)
                }
            }

            Section {
                if eligibleRecords.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing to add yet", systemImage: "doc.text")
                    } description: {
                        Text("Add activities, athletics, honors, or experiences and they can appear here automatically.")
                    }
                } else {
                    ForEach(sectionOrder, id: \.self) { moduleID in
                        let moduleRecords = eligibleRecords.filter { $0.moduleID == moduleID }
                        if !moduleRecords.isEmpty {
                            resumeSection(moduleID: moduleID, records: moduleRecords)
                        }
                    }
                }
            } header: {
                Text("Choose What to Include")
            } footer: {
                Text("Turn an item off here if you want to keep it in your Journey but leave it off this resume and future exports.")
            }

            Section("Create Your Resume") {
                Button {
                    Task { await createGoogleDoc() }
                } label: {
                    HStack {
                        Label("Create Editable Google Doc", systemImage: "doc.text.fill")
                        Spacer()
                        if isCreatingGoogleDoc { ProgressView() }
                    }
                }
                .disabled(isCreatingGoogleDoc || includedRecords.isEmpty || !GoogleOAuthService.shared.isConfigured)

                if !GoogleOAuthService.shared.isConfigured {
                    Label("Google Docs setup is required for this app build.", systemImage: "wrench.and.screwdriver")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let googleDocURL {
                    Link(destination: googleDocURL) {
                        Label("Open Resume in Google Docs", systemImage: "arrow.up.right.square")
                    }
                }

                Divider()

                Button {
                    createPDF()
                } label: {
                    HStack {
                        Label("Create PDF Copy", systemImage: "doc.richtext")
                        Spacer()
                        if isCreatingPDF { ProgressView() }
                    }
                }
                .disabled(isCreatingPDF || includedRecords.isEmpty)

                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share Resume PDF", systemImage: "square.and.arrow.up")
                    }
                }
            } footer: {
                Text("Google Docs is the editable working version. The PDF remains available when you are ready to submit or print a finished copy.")
            }
        }
        .navigationTitle("Resume")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fullName = profile?.preferredName ?? ""
            }
        }
        .alert(
            "Couldn’t Create Resume",
            isPresented: Binding(
                get: { exportError != nil },
                set: { if !$0 { exportError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { exportError = nil }
        } message: {
            Text(exportError ?? "Please try again.")
        }
    }

    @ViewBuilder
    private func resumeSection(moduleID: String, records: [ModuleRecord]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(sectionTitle(for: moduleID), systemImage: sectionIcon(for: moduleID))
                .font(.headline)

            ForEach(records) { record in
                Toggle(isOn: Binding(
                    get: { record.includeInExports },
                    set: { newValue in
                        record.includeInExports = newValue
                        record.updatedAt = Date()
                        try? modelContext.save()
                        exportURL = nil
                    }
                )) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.title)
                            .font(.subheadline.weight(.semibold))
                        if !record.organization.isEmpty || !record.role.isEmpty {
                            Text([record.organization, record.role]
                                .filter { !$0.isEmpty }
                                .joined(separator: " • "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var displayName: String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        let preferred = profile?.preferredName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return preferred.isEmpty ? "My Resume" : preferred
    }

    private func sectionTitle(for moduleID: String) -> String {
        switch moduleID {
        case "experiences": return "Experience"
        case "activities": return "Activities & Leadership"
        case "athletics": return "Athletics"
        case "honors": return "Honors & Awards"
        default: return "Journey"
        }
    }

    private func sectionIcon(for moduleID: String) -> String {
        ModuleRegistry.module(id: moduleID)?.systemImage ?? "circle.fill"
    }

    @MainActor
    private func createGoogleDoc() async {
        isCreatingGoogleDoc = true
        googleDocURL = nil
        defer { isCreatingGoogleDoc = false }

        let request = GoogleDocsResumeRequest(
            fullName: displayName,
            email: email,
            phone: phone,
            location: location,
            schoolName: profile?.schoolName ?? "",
            graduationYear: profile?.graduationYear,
            records: includedRecords.map {
                ResumeExportRecord(
                    moduleID: $0.moduleID,
                    title: $0.title,
                    date: $0.recordDate,
                    category: $0.category,
                    organization: $0.organization,
                    role: $0.role,
                    details: $0.details
                )
            }
        )

        do {
            googleDocURL = try await GoogleDocsResumeService.createResume(request: request)
            if let googleDocURL {
                UIApplication.shared.open(googleDocURL)
            }
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func createPDF() {
        isCreatingPDF = true
        exportURL = nil

        let request = ResumeExportRequest(
            fullName: displayName,
            email: email,
            phone: phone,
            location: location,
            schoolName: profile?.schoolName ?? "",
            graduationYear: profile?.graduationYear,
            includeHeadshot: includeHeadshot,
            headshotImageFilename: headshotImageFilename,
            records: includedRecords.map {
                ResumeExportRecord(
                    moduleID: $0.moduleID,
                    title: $0.title,
                    date: $0.recordDate,
                    category: $0.category,
                    organization: $0.organization,
                    role: $0.role,
                    details: $0.details
                )
            }
        )

        do {
            exportURL = try ResumeExportService.createPDF(request: request)
        } catch {
            exportError = error.localizedDescription
        }

        isCreatingPDF = false
    }
}
