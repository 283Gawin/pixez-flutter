import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            homeHeader
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 0.5)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("为你推荐")
                        .font(.system(size: 34, weight: .bold))
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
        .navigationBarHidden(true)
    }

    private var homeHeader: some View {
        ZStack {
            HStack {
                Text("亮点")
                    .font(.system(size: 30, weight: .bold))

                Spacer()

                Button {
                    appState.selectedTab = .more
                } label: {
                    Text("更多")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.82))
                }
            }
            .padding(.horizontal, 20)

            Circle()
                .fill(Color.black)
                .frame(width: 46, height: 46)
                .overlay {
                    Circle()
                        .trim(from: 0.72, to: 0.88)
                        .stroke(Color.blue, lineWidth: 2)
                        .rotationEffect(.degrees(-24))
                        .padding(7)
                }
        }
        .frame(height: 68)
        .background(Color(red: 0.075, green: 0.088, blue: 0.118))
    }
}