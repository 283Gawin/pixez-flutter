import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("推荐", systemImage: "house") }
            .tag(AppState.Tab.home)

            NavigationStack {
                SearchView()
            }
            .tabItem { Label("搜索", systemImage: "magnifyingglass") }
            .tag(AppState.Tab.search)

            NavigationStack {
                DownloadsView()
            }
            .tabItem { Label("下载", systemImage: "arrow.down.circle") }
            .tag(AppState.Tab.downloads)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("设置", systemImage: "gearshape") }
            .tag(AppState.Tab.settings)
        }
    }
}