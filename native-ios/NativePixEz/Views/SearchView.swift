import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        List {
            Section {
                EmptyStateView(
                    title: query.isEmpty ? "搜索 Pixiv" : "等待搜索接口",
                    message: query.isEmpty ? "输入作品、用户或标签" : "接口迁移完成后将在这里显示结果。",
                    systemImage: "magnifyingglass"
                )
                .frame(maxWidth: .infinity, minHeight: 260)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .navigationTitle("搜索")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
    }
}