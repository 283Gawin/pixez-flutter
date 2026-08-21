import SwiftUI

struct MainTabBar: View {
    @Binding var selection: AppState.Tab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppTheme.separator)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                tabItem(.home, title: "首页", icon: "house.fill")
                tabItem(.ranking, title: "排行", icon: "chart.bar.fill")
                tabItem(.quickView, title: "速览", icon: "heart.fill")
                tabItem(.search, title: "搜索", icon: "magnifyingglass")
                tabItem(.more, title: "更多", icon: "ellipsis")
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
        }
        .background(AppTheme.elevated)
    }

    private func tabItem(
        _ tab: AppState.Tab,
        title: String,
        icon: String
    ) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(selection == tab ? AppTheme.primaryText : AppTheme.secondaryText)
                    .frame(width: 56, height: 31)
                    .background {
                        Capsule()
                            .fill(selection == tab ? AppTheme.surface : .clear)
                    }

                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(selection == tab ? AppTheme.primaryText : AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}