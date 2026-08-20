import SwiftUI

struct IllustGridView: View {
    let items: [IllustPreview]
    let pipeline: ImagePipeline

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 6) {
                    RemoteImageView(url: item.imageURL, pipeline: pipeline)
                        .aspectRatio(item.aspectRatio, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(item.title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(2)
                    Text(item.userName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}