import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch appState.selectedTab {
                case .home:
                    NavigationStack {
                        HomeView()
                    }
                case .ranking:
                    NavigationStack {
                        RankingView()
                    }
                case .quickView:
                    NavigationStack {
                        QuickViewView()
                    }
                case .search:
                    NavigationStack {
                        SearchView()
                    }
                case .more:
                    NavigationStack {
                        MoreView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            MainTabBar(selection: $appState.selectedTab)
        }
        .background(Color(red: 0.043, green: 0.051, blue: 0.071))
        .preferredColorScheme(.dark)
    }
}