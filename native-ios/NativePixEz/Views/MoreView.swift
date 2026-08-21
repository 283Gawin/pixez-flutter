import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            Section("浏览") {
                NavigationLink {
                    DownloadsView()
                } label: {
                    Label("下载", systemImage: "arrow.down.circle")
                }
            }

            Section("设置") {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("设置", systemImage: "gearshape")
                }
            }
        }
        .navigationTitle("更多")
    }
}