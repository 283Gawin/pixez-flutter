import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

struct PixivLoginFlow {
    let codeVerifier: String
    let codeChallenge: String

    init(characterCount: Int = 128) throws {
        let allowedCharacters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let count = min(max(characterCount, 43), 128)
        var randomValues = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &randomValues)
        guard status == errSecSuccess else {
            throw PixivAPIError.badResponse
        }

        codeVerifier = String(randomValues.map { allowedCharacters[Int($0) % allowedCharacters.count] })
        let digest = SHA256.hash(data: Data(codeVerifier.utf8))
        codeChallenge = Data(digest)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func authorizationCode(from callbackURL: URL?) -> String? {
        guard let callbackURL else { return nil }
        let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first { $0.name == "code" }?.value
    }
}

final class WebAuthenticationPresenter: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
            ?? ASPresentationAnchor()
    }
}
