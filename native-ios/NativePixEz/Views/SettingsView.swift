import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            Section("账户") {
                HStack {
                    Label("Pixiv 账户", systemImage: "person.crop.circle")
                    Spacer()
                    Text(appState.isSignedIn ? "已登录" : "未登录")
                        .foregroundColor(.secondary)
                }
                Button(appState.isSignedIn ? "退出登录" : "登录") {
                    if appState.isSignedIn {
                        appState.signOut()
                    }
                }
                .disabled(!appState.isSignedIn)
            }

            Section("性能") {
                Label("按显示尺寸解码图片", systemImage: "photo")
                Label("页面离开后取消请求", systemImage: "xmark.circle")
                Label("动图按需加载", systemImage: "film")
            }

            Section("关于") {
                LabeledContent("版本", value: "0.1.0")
                LabeledContent("最低系统", value: "iOS 16.0")
            }
        }
        .navigationTitle("设置")
    }
}