import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("appLockEnabled") private var appLockEnabled = false

    @State private var selectedTab: RootTab = .home
    @State private var lastContentTab: RootTab = .home
    @State private var showingQuickAdd = false
    @State private var bootstrapError: String?
    @State private var isUnlocked = false

    var body: some View {
        Group {
            if shouldShowLock {
                AppLockView {
                    isUnlocked = true
                }
            } else {
                mainTabs
            }
        }
        .onAppear {
            if !appLockEnabled || !AppLockService.shared.isEnabled {
                isUnlocked = true
            }
        }
        .onChange(of: appLockEnabled) { _, newValue in
            if newValue {
                // The student just enabled App Lock from inside the app,
                // so keep the current session open. It will lock the next
                // time the app leaves the foreground.
                isUnlocked = true
            } else {
                isUnlocked = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background && appLockEnabled && AppLockService.shared.isEnabled {
                isUnlocked = false
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

    private var shouldShowLock: Bool {
        appLockEnabled && AppLockService.shared.isEnabled && !isUnlocked
    }

    private var mainTabs: some View {
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
    }
}

private enum RootTab: Hashable {
    case home
    case journey
    case add
    case search
    case settings
}
