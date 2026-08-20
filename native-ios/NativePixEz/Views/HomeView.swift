import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                if appState.homeItems.isEmpty {
                    EmptyStateView(
                        title: "准备开始",
                        message: "原生 iOS 数据层正在接入 Pixiv 接口。原 Flutter 功能会按模块迁移，不会一次性丢弃。",
                        systemImage: "sparkles"
                    )
                    .frame(maxWidth: .infinity, minHeight: 360)
                } else {
                    IllustGridView(items: appState.homeItems, pipeline: appState.imagePipeline)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle("PixEz")
        .refreshable { }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("原生 iOS 版本")
                .font(.title2.weight(.semibold))
            Text("iOS 16 · SwiftUI · 低功耗图片管线")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}