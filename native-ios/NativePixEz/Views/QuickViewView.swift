import SwiftUI

struct QuickViewView: View {
    enum QuickSegment: String, CaseIterable, Identifiable {
        case moments = "动态"
        case bookmarks = "收藏"
        case updates = "追更列表"
        case followed = "已关注"

        var id: String { rawValue }
    }

    enum VisibilityFilter: String, CaseIterable, Identifiable {
        case all = "全部"
        case publicMode = "公开"
        case privateMode = "非公开"

        var id: String { rawValue }
    }

    @State private var selectedSegment: QuickSegment = .moments
    @State private var visibilityFilter: VisibilityFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                visibilityPicker
                    .padding(.top, 18)

                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, minHeight: 420)
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 20) {
            HStack(spacing: 22) {
                ForEach(QuickSegment.allCases) { segment in
                    Button {
                        selectedSegment = segment
                    } label: {
                        Text(segment.rawValue)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(selectedSegment == segment ? Color(red: 0.37, green: 0.62, blue: 0.98) : .white.opacity(0.72))
                            .padding(.vertical, 14)
                            .background(alignment: .bottom) {
                                Capsule()
                                    .fill(selectedSegment == segment ? Color(red: 0.37, green: 0.62, blue: 0.98) : .clear)
                                    .frame(width: 38, height: 4)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.32, green: 0.48, blue: 0.92), Color(red: 0.72, green: 0.34, blue: 0.58)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .background(Color(red: 0.075, green: 0.088, blue: 0.118))
    }

    private var visibilityPicker: some View {
        HStack(spacing: 0) {
            ForEach(VisibilityFilter.allCases) { filter in
                Button {
                    visibilityFilter = filter
                } label: {
                    HStack(spacing: 7) {
                        if visibilityFilter == filter {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                        }

                        Text(filter.rawValue)
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 47)
                    .background(visibilityFilter == filter ? Color.white.opacity(0.16) : .clear)
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.24), lineWidth: 1))
        .padding(.horizontal, 70)
    }
}