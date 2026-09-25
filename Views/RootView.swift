import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: RootTab = .home
    @State private var lastContentTab: RootTab = .home
    @State private var showingQuickAdd = false
    @State private var bootstrapError: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tag(RootTab.home)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                JourneyView()
            }
            .tag(RootTab.journey)
            .tabItem {
                Label("Journey", systemImage: "sparkles.rectangle.stack")
            }

            Color.clear
                .tag(RootTab.add)
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            NavigationStack {
                SearchView()
            }
            .tag(RootTab.search)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                SettingsView()
            }
            .tag(RootTab.settings)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .add {
                selectedTab = lastContentTab
                showingQuickAdd = true
            } else {
                lastContentTab = newValue
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddView()
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

private enum RootTab: Hashable {
    case home
    case journey
    case add
    case search
    case settings
}
