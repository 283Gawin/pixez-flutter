import Foundation

struct PixivAccount: Codable, Equatable, Sendable {
    let userID: String
    let name: String
    let accountName: String
    let mailAddress: String
    let avatarURL: URL?
    let accessToken: String
    let refreshToken: String
}

struct PixivAuthEnvelope: Decodable {
    let response: PixivToken
}

struct PixivToken: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: PixivAuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct PixivAuthUser: Decodable {
    let id: String
    let name: String
    let account: String
    let mailAddress: String
    let profileImageUrls: ProfileImageUrls?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case account
        case mailAddress = "mail_address"
        case profileImageUrls = "profile_image_urls"
    }
}

struct ProfileImageUrls: Decodable, Hashable, Sendable {
    let medium: URL?
}

struct RecommendedIllusts: Decodable, Sendable {
    let illusts: [PixivIllust]
    let nextPageURL: String?

    enum CodingKeys: String, CodingKey {
        case illusts
        case nextPageURL = "next_url"
    }
}

struct PixivIllust: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let type: String
    let caption: String?
    let imageUrls: ImageURLSet
    let pageCount: Int
    let width: Int
    let height: Int
    let xRestrict: Int
    let user: PixivUser

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case type
        case caption
        case imageUrls = "image_urls"
        case pageCount = "page_count"
        case width
        case height
        case xRestrict = "x_restrict"
        case user
    }
}

struct ImageURLSet: Decodable, Hashable, Sendable {
    let squareMedium: URL?
    let medium: URL?
    let large: URL?

    enum CodingKeys: String, CodingKey {
        case squareMedium = "square_medium"
        case medium
        case large
    }
}

struct PixivUser: Decodable, Hashable, Sendable {
    let id: Int
    let name: String
    let account: String
    let profileImageURLs: ProfileImageUrls?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case account
        case profileImageURLs = "profile_image_urls"
    }
}

extension PixivIllust {
    var preview: IllustPreview {
        IllustPreview(
            id: id,
            title: title,
            userName: user.name,
            imageURL: imageUrls.medium ?? imageUrls.squareMedium,
            aspectRatio: height == 0 ? 1 : CGFloat(width) / CGFloat(height)
        )
    }
}
