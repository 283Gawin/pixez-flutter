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
    @Published var isSignedIn = true
    @Published var userName = "歌者283"
    @Published var maskedEmail = "**************@gmail.com"
    @Published var emailAddress = ""
    @Published var isLoadingHome = false
    @Published var homeItems: [IllustPreview] = []

    let imagePipeline = ImagePipeline()
    let apiClient = PixivAPIClient()

    func signOut() {
        isSignedIn = false
        userName = ""
        maskedEmail = ""
        emailAddress = ""
        isLoadingHome = false
        homeItems = []
    }
}