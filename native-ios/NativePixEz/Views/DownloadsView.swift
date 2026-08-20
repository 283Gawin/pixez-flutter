import SwiftUI

struct DownloadsView: View {
    var body: some View {
        List {
            EmptyStateView(
                title: "暂无下载任务",
                message: "下载队列会使用原生后台任务与可取消的并发控制。",
                systemImage: "arrow.down.circle"
            )
            .frame(maxWidth: .infinity, minHeight: 260)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .navigationTitle("下载")
    }
}