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

    @EnvironmentObject private var appState: AppState
    @State private var selectedSegment: QuickSegment = .moments
    @State private var visibilityFilter: VisibilityFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                if showsVisibilityFilter {
                    visibilityPicker
                        .padding(.top, 18)
                        .padding(.horizontal, 24)
                }

                Group {
                    if appState.isSignedIn {
                        ProgressView()
                            .tint(AppTheme.accent)
                    } else {
                        EmptyStateView(
                            title: "需要登录",
                            message: "登录 Pixiv 后即可查看速览内容。",
                            systemImage: "person.crop.circle.badge.exclamationmark"
                        )
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 420)
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }

    private var showsVisibilityFilter: Bool {
        selectedSegment == .moments || selectedSegment == .bookmarks
    }

    private var header: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(QuickSegment.allCases) { segment in
                    Button {
                        selectedSegment = segment
                    } label: {
                        Text(segment.rawValue)
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(selectedSegment == segment ? AppTheme.accent : AppTheme.secondaryText)
                            .padding(.vertical, 14)
                            .background(alignment: .bottom) {
                                Capsule()
                                    .fill(selectedSegment == segment ? AppTheme.accent : .clear)
                                    .frame(width: 36, height: 4)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 1)
        }
        .background(AppTheme.elevated)
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
                                .font(.system(size: 13, weight: .bold))
                        }

                        Text(filter.rawValue)
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(AppTheme.primaryText)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(visibilityFilter == filter ? AppTheme.surface : .clear)
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppTheme.separator, lineWidth: 1))
    }
}