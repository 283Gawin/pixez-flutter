import Foundation

struct IllustPreview: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let userName: String
    let imageURL: URL?
    let aspectRatio: CGFloat

    init(
        id: Int,
        title: String,
        userName: String,
        imageURL: URL? = nil,
        aspectRatio: CGFloat = 1.0
    ) {
        self.id = id
        self.title = title
        self.userName = userName
        self.imageURL = imageURL
        self.aspectRatio = max(aspectRatio, 0.35)
    }
}