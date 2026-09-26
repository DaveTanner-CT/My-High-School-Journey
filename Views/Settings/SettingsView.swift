import SwiftUI
import SwiftData
import PhotosUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [StudentProfile]
    @AppStorage("appLockEnabled") private var appLockEnabled = false

    var body: some View {
        Form {
            Section("My Profile") {
                if let profile = profiles.first {
                    ProfileEditor(profile: profile)
                } else {
                    Text("Setting up your profile…")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Customize") {
                NavigationLink("Home Screen") {
                    HomeScreenSettingsView()
                }
            }

            Section("Privacy") {
                NavigationLink {
                    AppLockSettingsView()
                } label: {
                    HStack {
                        Label("App Lock", systemImage: "lock.shield")
                        Spacer()
                        Text(appLockEnabled && AppLockService.shared.isEnabled ? "On" : "Off")
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Your Journey is private by default. App Lock can add an optional four-digit PIN on this device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Data") {
                Text("Export, backup and iCloud status will be added as dedicated services rather than being embedded in individual screens.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                HStack {
                    Spacer()
                    Text(AppVersionInfo.displayText)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Settings")
    }
}

private enum AppVersionInfo {
    static var displayText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "Version \(version) (\(build))"
    }
}

private struct ProfileEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: StudentProfile
    @AppStorage("profileHeadshotImageFilename") private var headshotImageFilename = ""
    @AppStorage("profileHeadshotThumbnailFilename") private var headshotThumbnailFilename = ""

    @State private var selectedHeadshot: PhotosPickerItem?
    @State private var isSavingHeadshot = false
    @State private var headshotError: String?

    var body: some View {
        VStack(spacing: 12) {
            ProfileHeadshotView(
                thumbnailFilename: headshotThumbnailFilename,
                size: 92
            )

            PhotosPicker(selection: $selectedHeadshot, matching: .images) {
                Label(
                    headshotThumbnailFilename.isEmpty ? "Add Headshot" : "Change Headshot",
                    systemImage: "person.crop.circle.badge.plus"
                )
            }
            .disabled(isSavingHeadshot)

            if !headshotThumbnailFilename.isEmpty {
                Button("Remove Headshot", role: .destructive) {
                    removeHeadshot()
                }
                .font(.footnote)
            }

            if isSavingHeadshot {
                ProgressView("Saving photo…")
                    .font(.footnote)
            }

            Text("Optional. Your headshot can be used later in resume and profile tools.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .onChange(of: selectedHeadshot) { _, newItem in
            guard let newItem else { return }
            Task { await saveHeadshot(newItem) }
        }
        .alert(
            "Couldn’t Save Headshot",
            isPresented: Binding(
                get: { headshotError != nil },
                set: { if !$0 { headshotError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { headshotError = nil }
        } message: {
            Text(headshotError ?? "Please try another photo.")
        }

        TextField("Preferred name", text: $profile.preferredName)
            .onChange(of: profile.preferredName) { _, _ in save() }

        TextField("School (optional)", text: $profile.schoolName)
            .onChange(of: profile.schoolName) { _, _ in save() }

        Stepper(value: $profile.graduationYear, in: 2026...2045) {
            Text("Class of \(profile.graduationYear, format: .number.grouping(.never))")
        }
        .onChange(of: profile.graduationYear) { _, _ in save() }
    }

    @MainActor
    private func saveHeadshot(_ item: PhotosPickerItem) async {
        isSavingHeadshot = true
        defer {
            isSavingHeadshot = false
            selectedHeadshot = nil
        }

        do {
            let files = try await PhotoStorageService.savePickerItem(item, id: UUID())
            let oldImage = headshotImageFilename
            let oldThumbnail = headshotThumbnailFilename

            headshotImageFilename = files.imageFilename
            headshotThumbnailFilename = files.thumbnailFilename

            if !oldImage.isEmpty || !oldThumbnail.isEmpty {
                PhotoStorageService.deleteFiles(
                    imageFilename: oldImage,
                    thumbnailFilename: oldThumbnail
                )
            }
        } catch {
            headshotError = error.localizedDescription
        }
    }

    private func removeHeadshot() {
        PhotoStorageService.deleteFiles(
            imageFilename: headshotImageFilename,
            thumbnailFilename: headshotThumbnailFilename
        )
        headshotImageFilename = ""
        headshotThumbnailFilename = ""
    }

    private func save() {
        profile.updatedAt = Date()
        try? modelContext.save()
    }
}
