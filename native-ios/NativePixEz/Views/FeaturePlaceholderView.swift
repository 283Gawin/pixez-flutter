import SwiftUI

struct FeaturePlaceholderView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        ScrollView {
            EmptyStateView(title: title, message: message, systemImage: systemImage)
                .frame(maxWidth: .infinity, minHeight: 420)
        }
        .background(AppTheme.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}