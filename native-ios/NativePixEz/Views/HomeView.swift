import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            homeHeader
            Rectangle()
                .fill(AppTheme.separator)
                .frame(height: 0.5)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("为你推荐")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)
                        .padding(.top, 28)

                    if appState.homeItems.isEmpty {
                        EmptyStateView(
                            title: "内容准备中",
                            message: "Pixiv 推荐接口接入后，这里会显示作品流。",
                            systemImage: "sparkles"
                        )
                        .frame(maxWidth: .infinity, minHeight: 320)
                    } else {
                        IllustGridView(items: appState.homeItems, pipeline: appState.imagePipeline)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }

    private var homeHeader: some View {
        ZStack {
            HStack {
                Text("亮点")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)

                Spacer()

                Button {
                    appState.selectedTab = .more
                } label: {
                    Text("更多")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.horizontal, 20)

            Circle()
                .fill(AppTheme.subtleFill)
                .overlay(Circle().stroke(AppTheme.separator, lineWidth: 1))
                .frame(width: 46, height: 46)
                .overlay {
                    Circle()
                        .trim(from: 0.72, to: 0.88)
                        .stroke(AppTheme.accent, lineWidth: 2)
                        .rotationEffect(.degrees(-24))
                        .padding(7)
                }
        }
        .frame(height: 68)
        .background(AppTheme.elevated)
    }
}