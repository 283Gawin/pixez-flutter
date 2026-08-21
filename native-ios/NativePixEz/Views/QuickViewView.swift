import SwiftUI

struct QuickViewView: View {
    var body: some View {
        List {
            EmptyStateView(
                title: "速览",
                message: "收藏与快速浏览入口会集中在这里。",
                systemImage: "heart.fill"
            )
            .frame(maxWidth: .infinity, minHeight: 300)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .navigationTitle("速览")
    }
}