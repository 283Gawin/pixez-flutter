import CryptoKit
import Foundation

actor PixivAPIClient {
    private enum Credentials {
        static let clientID = "MOBrBDS8blbauoSck0ZfDbtuzpyT"
        static let clientSecret = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj"
        static let hashSalt = "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c"
    }

    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    nonisolated static func webAuthorizationURL(
        createAccount: Bool,
        codeChallenge: String
    ) -> URL {
        let path = createAccount
            ? "/web/v1/provisional-accounts/create"
            : "/web/v1/login"
        var components = URLComponents(string: "https://app-api.pixiv.net\(path)")!
        components.queryItems = [
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "client", value: "pixiv-android")
        ]
        return components.url!
    }

    func login(username: String, password: String) async throws -> PixivAccount {
        try await authenticate(fields: [
            "client_id": Credentials.clientID,
            "client_secret": Credentials.clientSecret,
            "grant_type": "password",
            "username": username,
            "password": password,
            "Device_token": "pixiv",
            "get_secure_url": "true",
            "include_policy": "true"
        ])
    }

    func exchangeAuthorizationCode(code: String, codeVerifier: String) async throws -> PixivAccount {
        try await authenticate(fields: [
            "code": code,
            "redirect_uri": "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback",
            "grant_type": "authorization_code",
            "include_policy": "true",
            "client_id": Credentials.clientID,
            "code_verifier": codeVerifier,
            "client_secret": Credentials.clientSecret
        ])
    }

    func refresh(refreshToken: String) async throws -> PixivAccount {
        try await authenticate(fields: [
            "client_id": Credentials.clientID,
            "client_secret": Credentials.clientSecret,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "include_policy": "true"
        ])
    }

    func recommended(accessToken: String) async throws -> RecommendedIllusts {
        var components = URLComponents(string: "https://app-api.pixiv.net/v1/illust/recommended")
        components?.queryItems = [
            URLQueryItem(name: "filter", value: "for_ios"),
            URLQueryItem(name: "include_ranking_label", value: "true")
        ]

        var request = URLRequest(url: components?.url ?? URL(string: "https://app-api.pixiv.net/v1/illust/recommended")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        addCommonHeaders(to: &request)
        return try await run(request, recognizesAuthFailure: true)
    }

    private func authenticate(fields: [String: String]) async throws -> PixivAccount {
        guard let url = URL(string: "https://oauth.secure.pixiv.net/auth/token") else {
            throw PixivAPIError.badResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        addCommonHeaders(to: &request)
        request.httpBody = Self.formBody(for: fields)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw PixivAPIError.badResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw PixivAPIError.requestFailed(status: http.statusCode, data: data)
        }

        let envelope = try decoder.decode(PixivAuthEnvelope.self, from: data)
        let user = envelope.response.user
        return PixivAccount(
            userID: user.id,
            name: user.name,
            accountName: user.account,
            mailAddress: user.mailAddress,
            avatarURL: user.profileImageUrls?.medium,
            accessToken: envelope.response.accessToken,
            refreshToken: envelope.response.refreshToken
        )
    }

    private func run<T: Decodable>(
        _ request: URLRequest,
        recognizesAuthFailure: Bool
    ) async throws -> T where T: Sendable {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw PixivAPIError.badResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            if recognizesAuthFailure,
               isAuthenticationFailure(status: http.statusCode, data: data) {
                throw PixivAPIError.authenticationExpired
            }
            throw PixivAPIError.requestFailed(status: http.statusCode, data: data)
        }
        return try decoder.decode(T.self, from: data)
    }

    private func isAuthenticationFailure(status: Int, data: Data) -> Bool {
        if status == 401 || status == 403 {
            return true
        }
        guard status == 400,
              let body = String(data: data, encoding: .utf8),
              body.localizedCaseInsensitiveContains("OAuth") else {
            return false
        }
        return true
    }

    private func addCommonHeaders(to request: inout URLRequest) {
        let timestamp = Self.isoTimestamp()
        request.setValue(timestamp, forHTTPHeaderField: "X-Client-Time")
        request.setValue(Self.md5(timestamp + Credentials.hashSalt), forHTTPHeaderField: "X-Client-Hash")
        request.setValue("PixivAndroidApp/5.0.155 (Android 10.0; Pixel C)", forHTTPHeaderField: "User-Agent")
        request.setValue("zh-CN", forHTTPHeaderField: "Accept-Language")
        request.setValue("Android", forHTTPHeaderField: "App-OS")
        request.setValue("Android 10.0", forHTTPHeaderField: "App-OS-Version")
        request.setValue("5.0.166", forHTTPHeaderField: "App-Version")
        request.setValue("https://app-api.pixiv.net/", forHTTPHeaderField: "Referer")
    }

    nonisolated private static func formBody(for fields: [String: String]) -> Data {
        var components = URLComponents()
        components.queryItems = fields.map { URLQueryItem(name: $0.key, value: $0.value) }
        let query = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%20") ?? ""
        return Data(query.utf8)
    }

    nonisolated private static func isoTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+00:00'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: Date())
    }

    nonisolated private static func md5(_ source: String) -> String {
        Insecure.MD5.hash(data: Data(source.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

enum PixivAPIError: Error, LocalizedError {
    case badResponse
    case authenticationExpired
    case requestFailed(status: Int, data: Data)

    var errorDescription: String? {
        switch self {
        case .badResponse:
            return "网络返回格式不正确。"
        case .authenticationExpired:
            return "登录已过期，请重新登录。"
        case .requestFailed(let status, let data):
            if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = object["error"] as? [String: Any],
               let message = error["message"] as? String,
               !message.isEmpty {
                return "Pixiv 请求失败（\(status)）：\(message)"
            }
            return "Pixiv 请求失败（\(status)）。"
        }
    }
}
