import SwiftUI

struct RankingView: View {
    var body: some View {
        List {
            EmptyStateView(
                title: "排行榜",
                message: "作品榜单接口迁移完成后显示。",
                systemImage: "chart.bar.fill"
            )
            .frame(maxWidth: .infinity, minHeight: 300)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .navigationTitle("排行")
    }
}