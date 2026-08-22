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

                    if appState.isLoadingHome {
                        ProgressView()
                            .tint(AppTheme.accent)
                            .frame(maxWidth: .infinity, minHeight: 320)
                    } else if let message = appState.homeErrorMessage {
                        errorState(message)
                    } else if !appState.isSignedIn {
                        EmptyStateView(
                            title: "需要登录",
                            message: "登录 Pixiv 后即可查看推荐内容。",
                            systemImage: "person.crop.circle.badge.exclamationmark"
                        )
                        .frame(maxWidth: .infinity, minHeight: 320)
                    } else if appState.homeItems.isEmpty {
                        EmptyStateView(
                            title: "暂无推荐",
                            message: "Pixiv 推荐接口没有返回内容。",
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
        .task(id: appState.account?.userID) {
            await appState.loadHomeIfNeeded()
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("重试") {
                Task {
                    await appState.retryLoadingHome()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 280)
    }

    private var homeHeader: some View {
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
        .frame(height: 62)
        .background(AppTheme.elevated)
    }
}
