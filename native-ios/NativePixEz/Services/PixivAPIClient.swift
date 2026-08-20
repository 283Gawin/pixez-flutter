import Foundation

actor PixivAPIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ request: URLRequest, decode type: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PixivAPIError.badResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum PixivAPIError: Error {
    case badResponse
}