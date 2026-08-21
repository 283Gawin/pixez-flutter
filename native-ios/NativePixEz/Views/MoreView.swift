import SwiftUI

struct MoreView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isEmailVisible = false
    @State private var isLogoutConfirmationPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    NavigationLink {
                        FeaturePlaceholderView(
                            title: "外观",
                            message: "主题与显示设置会在偏好设置迁移时补齐。",
                            systemImage: "paintpalette"
                        )
                    } label: {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(AppTheme.primaryText)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                accountCard
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                menuDivider
                    .padding(.vertical, 10)

                VStack(spacing: 0) {
                    navigationRow(icon: "person.text.rectangle", title: "账户信息") {
                        FeaturePlaceholderView(title: "账户信息", message: "账户编辑页面待迁移。", systemImage: "person.text.rectangle")
                    }
                    navigationRow(icon: "clock.arrow.circlepath", title: "历史记录") {
                        FeaturePlaceholderView(title: "历史记录", message: "浏览历史存储和列表待迁移。", systemImage: "clock.arrow.circlepath")
                    }
                    navigationRow(icon: "gearshape.fill", title: "偏好设置") {
                        SettingsView()
                    }
                    navigationRow(icon: "bookmark.fill", title: "收藏标签") {
                        FeaturePlaceholderView(title: "收藏标签", message: "收藏标签读取和管理待迁移。", systemImage: "bookmark.fill")
                    }
                    navigationRow(icon: "nosign", title: "屏蔽设定") {
                        FeaturePlaceholderView(title: "屏蔽设定", message: "用户、标签和 AI 屏蔽规则待迁移。", systemImage: "nosign")
                    }
                    navigationRow(icon: "arrow.down.to.line", title: "任务进度") {
                        DownloadsView()
                    }
                    navigationRow(icon: "folder", title: "应用数据") {
                        FeaturePlaceholderView(title: "应用数据", message: "导入导出与缓存管理待迁移。", systemImage: "folder")
                    }
                }

                menuDivider
                    .padding(.vertical, 10)

                VStack(spacing: 0) {
                    navigationRow(icon: "books.vertical.fill", title: "漫画") {
                        FeaturePlaceholderView(title: "漫画", message: "漫画推荐页待迁移。", systemImage: "books.vertical.fill")
                    }
                    navigationRow(icon: "book.closed.fill", title: "小说") {
                        FeaturePlaceholderView(title: "小说", message: "小说浏览页待迁移。", systemImage: "book.closed.fill")
                    }
                }

                menuDivider
                    .padding(.vertical, 10)

                VStack(spacing: 0) {
                    navigationRow(icon: "info.circle", title: "关于") {
                        FeaturePlaceholderView(title: "关于", message: "版本、开源许可和更新信息待迁移。", systemImage: "info.circle")
                    }

                    if appState.isSignedIn {
                        Button {
                            isLogoutConfirmationPresented = true
                        } label: {
                            Label("退出登录", systemImage: "arrow.uturn.backward")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                        } label: {
                            Label("登录", systemImage: "arrow.right.circle")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(AppTheme.accent)
                                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
        .confirmationDialog(
            "退出登录",
            isPresented: $isLogoutConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("退出", role: .destructive) {
                appState.signOut()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这将清除本机登录账户信息并回到未登录状态。")
        }
    }

    private var accountCard: some View {
        Group {
            if appState.isSignedIn {
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle().fill(
                            LinearGradient(
                                colors: [AppTheme.accent, Color(red: 0.72, green: 0.34, blue: 0.58)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        Text(String(appState.userName.prefix(1)))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 68, height: 68)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(appState.userName)
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)

                        HStack(spacing: 8) {
                            Text(displayEmail)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppTheme.secondaryText)

                            Button {
                                isEmailVisible.toggle()
                            } label: {
                                Text(isEmailVisible ? "隐藏" : "显示")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppTheme.accent)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 42))
                        .foregroundColor(AppTheme.secondaryText)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("未登录")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                        Text("登录后同步账户数据")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var displayEmail: String {
        if isEmailVisible {
            return appState.emailAddress.isEmpty ? "邮箱未同步" : appState.emailAddress
        }
        return appState.maskedEmail
    }

    private var menuDivider: some View {
        Rectangle()
            .fill(AppTheme.separator)
            .frame(height: 0.5)
    }

    private func navigationRow<Destination: View>(
        icon: String,
        title: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .regular))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}