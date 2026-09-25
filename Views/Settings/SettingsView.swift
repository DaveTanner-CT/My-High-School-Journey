import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [StudentProfile]

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
                Label("Your Journey is private by default.", systemImage: "lock.shield.fill")
                Text("More privacy and Face ID controls will be added after the core data architecture is proven.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Data") {
                Text("Export, backup and iCloud status will be added as dedicated services rather than being embedded in individual screens.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

private struct ProfileEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: StudentProfile

    var body: some View {
        TextField("Preferred name", text: $profile.preferredName)
            .onChange(of: profile.preferredName) { _, _ in save() }

        TextField("School (optional)", text: $profile.schoolName)
            .onChange(of: profile.schoolName) { _, _ in save() }

        Stepper(value: $profile.graduationYear, in: 2026...2045) {
            Text("Class of \(profile.graduationYear, format: .number.grouping(.never))")
        }
        .onChange(of: profile.graduationYear) { _, _ in save() }
    }

    private func save() {
        profile.updatedAt = Date()
        try? modelContext.save()
    }
}
