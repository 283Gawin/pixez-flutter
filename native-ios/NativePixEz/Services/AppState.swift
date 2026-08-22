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
    @Published private(set) var account: PixivAccount?
    @Published var isLoadingHome = false
    @Published var homeItems: [IllustPreview] = []
    @Published var homeErrorMessage: String?

    let imagePipeline = ImagePipeline()
    let apiClient = PixivAPIClient()
    private let keychain = KeychainStore()

    init() {
        account = keychain.load(PixivAccount.self, account: "current")
    }

    var isSignedIn: Bool {
        account != nil
    }

    var userName: String {
        account?.name ?? ""
    }

    var emailAddress: String {
        account?.mailAddress ?? ""
    }

    var maskedEmail: String {
        let mail = emailAddress
        guard !mail.isEmpty, let separator = mail.firstIndex(of: "@") else {
            return ""
        }
        let localPartCount = mail.distance(from: mail.startIndex, to: separator)
        return String(repeating: "*", count: localPartCount) + mail[separator...]
    }

    func login(username: String, password: String) async throws {
        let newAccount = try await apiClient.login(username: username, password: password)
        storeAccount(newAccount)
        await loadHome(force: true)
    }

    func completeThirdPartyLogin(code: String, codeVerifier: String) async throws {
        let newAccount = try await apiClient.exchangeAuthorizationCode(
            code: code,
            codeVerifier: codeVerifier
        )
        storeAccount(newAccount)
        await loadHome(force: true)
    }

    func loadHomeIfNeeded() async {
        await loadHome(force: false)
    }

    func retryLoadingHome() async {
        await loadHome(force: true)
    }

    func signOut() {
        keychain.delete(account: "current")
        account = nil
        isLoadingHome = false
        homeItems = []
        homeErrorMessage = nil
    }

    private func loadHome(force: Bool) async {
        guard isSignedIn else {
            homeErrorMessage = "请先登录 Pixiv。"
            return
        }
        guard force || homeItems.isEmpty, !isLoadingHome else {
            return
        }

        isLoadingHome = true
        homeErrorMessage = nil

        defer {
            isLoadingHome = false
        }

        do {
            let result = try await authorizedRecommended()
            homeItems = result.illusts.map(\.preview)
        } catch {
            homeErrorMessage = error.localizedDescription
        }
    }

    private func authorizedRecommended() async throws -> RecommendedIllusts {
        guard let currentAccount = account else {
            throw PixivAPIError.authenticationExpired
        }

        do {
            return try await apiClient.recommended(accessToken: currentAccount.accessToken)
        } catch PixivAPIError.authenticationExpired {
            let renewedAccount = try await apiClient.refresh(refreshToken: currentAccount.refreshToken)
            storeAccount(renewedAccount)
            return try await apiClient.recommended(accessToken: renewedAccount.accessToken)
        }
    }

    private func storeAccount(_ value: PixivAccount) {
        try? keychain.save(value, account: "current")
        account = value
    }
}
