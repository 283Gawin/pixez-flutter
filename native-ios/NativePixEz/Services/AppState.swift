import Foundation

@MainActor
final class AppState: ObservableObject {
    enum Tab: Hashable {
        case home
        case search
        case downloads
        case settings
    }

    @Published var selectedTab: Tab = .home
    @Published var isSignedIn = false
    @Published var homeItems: [IllustPreview] = []

    let imagePipeline = ImagePipeline()
    let apiClient = PixivAPIClient()

    func signOut() {
        isSignedIn = false
        homeItems = []
    }
}