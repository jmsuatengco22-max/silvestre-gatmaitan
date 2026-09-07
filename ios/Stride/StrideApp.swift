import SwiftUI

@main
struct StrideApp: App {
    @StateObject private var store = WalkStore()
    @State private var selectedTab: TabDestination = .today
    @State private var showLogSheet = false

    enum TabDestination {
        case today
        case history
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                TodayView(store: store, showLogSheet: $showLogSheet)
                    .tabItem {
                        Label("Today", systemImage: "figure.walk")
                    }
                    .tag(TabDestination.today)

                HistoryView(store: store, showLogSheet: $showLogSheet)
                    .tabItem {
                        Label("History", systemImage: "chart.bar.xaxis")
                    }
                    .tag(TabDestination.history)
            }
            .tint(AppTheme.primary)
            .sheet(isPresented: $showLogSheet) {
                LogWalkView(store: store)
            }
            .onAppear {
                setupAppearance()
            }
        }
    }

    private func setupAppearance() {
        // Soften tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(AppTheme.surface)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
