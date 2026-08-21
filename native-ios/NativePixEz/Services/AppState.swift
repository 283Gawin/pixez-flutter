import Foundation

@MainActor
final class AppState: ObservableObject {
    enum Tab: Hashable {
        case home
        case ranking
        case quickView
        case search
        case more
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