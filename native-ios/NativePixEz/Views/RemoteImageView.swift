import SwiftUI
import UIKit

struct RemoteImageView: View {
    let url: URL?
    let pipeline: ImagePipeline

    var body: some View {
        Group {
            if let url {
                LoadedRemoteImage(url: url, pipeline: pipeline)
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.secondary.opacity(0.12))
            .overlay(Image(systemName: "photo").foregroundColor(.secondary))
            .frame(minHeight: 150)
    }
}

private struct LoadedRemoteImage: View {
    let url: URL
    let pipeline: ImagePipeline
    @StateObject private var loader: RemoteImageLoader

    init(url: URL, pipeline: ImagePipeline) {
        self.url = url
        self.pipeline = pipeline
        _loader = StateObject(wrappedValue: RemoteImageLoader(url: url, pipeline: pipeline))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if loader.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                Image(systemName: "photo.badge.exclamationmark")
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .foregroundColor(.secondary)
            }
        }
        .clipped()
        .task(id: url) {
            await loader.load()
        }
    }
}

@MainActor
private final class RemoteImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading = false

    private let url: URL
    private let pipeline: ImagePipeline

    init(url: URL, pipeline: ImagePipeline) {
        self.url = url
        self.pipeline = pipeline
    }

    func load() async {
        guard image == nil, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            image = try await pipeline.image(for: url, maxPixelSize: 900)
        } catch is CancellationError {
            return
        } catch {
            image = nil
        }
    }
}