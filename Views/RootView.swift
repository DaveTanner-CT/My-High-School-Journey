import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var bootstrapError: String?

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                JourneyView()
            }
            .tabItem {
                Label("Journey", systemImage: "sparkles.rectangle.stack")
            }

            NavigationStack {
                ModulePlaceholderView(
                    title: "Trusted Resources",
                    message: "Official national resources will live here and will also appear inside the modules where they are useful.",
                    systemImage: "checkmark.seal.fill"
                )
            }
            .tabItem {
                Label("Resources", systemImage: "checkmark.seal.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .task {
            do {
                try BootstrapService.prepare(modelContext: modelContext)
            } catch {
                bootstrapError = error.localizedDescription
            }
        }
        .alert("High School Journey couldn't finish setup", isPresented: Binding(
            get: { bootstrapError != nil },
            set: { if !$0 { bootstrapError = nil } }
        )) {
            Button("OK", role: .cancel) { bootstrapError = nil }
        } message: {
            Text(bootstrapError ?? "Unknown error")
        }
    }
}
