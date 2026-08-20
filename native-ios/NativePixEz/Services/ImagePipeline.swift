import ImageIO
import UIKit

actor ImagePipeline {
    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL, maxPixelSize: CGFloat) async throws -> UIImage {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 30
        )
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode ?? 200 < 400 else {
            throw ImagePipelineError.badResponse
        }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImagePipelineError.invalidImage
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: false,
            kCGImageSourceThumbnailMaxPixelSize: max(1, Int(maxPixelSize))
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw ImagePipelineError.invalidImage
        }

        let image = UIImage(cgImage: cgImage)
        cache.setObject(image, forKey: key)
        return image
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}

enum ImagePipelineError: Error {
    case badResponse
    case invalidImage
}