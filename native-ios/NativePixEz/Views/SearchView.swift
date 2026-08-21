import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: maxWidth == .infinity ? max(0, x - spacing) : maxWidth, height: max(0, y + rowHeight - spacing))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct SearchView: View {
    @State private var query = ""
    @State private var history: [String] = []
    @State private var isClearConfirmationPresented = false
    @State private var isImageSearchAlertPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                searchBar
                Text("搜索")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)

                if !history.isEmpty {
                    historySection
                }

                recommendedSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
        .confirmationDialog(
            "清空搜索历史",
            isPresented: $isClearConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("清空", role: .destructive) {
                history.removeAll()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("将删除本机保存的搜索历史。")
        }
        .alert("以图搜图", isPresented: $isImageSearchAlertPresented) {
            Button("好") {}
        } message: {
            Text("SauceNao 搜索将在后续迁移中接入。")
        }
    }

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)

            TextField(
                "搜索标题或画师昵称",
                text: $query
            )
            .font(.system(size: 16))
            .foregroundColor(AppTheme.primaryText)
            .submitLabel(.search)
            .onSubmit(addCurrentQuery)

            Button {
                isImageSearchAlertPresented = true
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 14)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity, minHeight: 48)
        .background(AppTheme.subtleFill)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("历史")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)

            FlowLayout(spacing: 8) {
                ForEach(history, id: \.self) { tag in
                    Button {
                        query = tag
                    } label: {
                        Text(tag)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.primaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppTheme.subtleFill)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            history.removeAll { $0 == tag }
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }

            Button {
                isClearConfirmationPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("清空搜索历史")
                }
                .font(.system(size: 14))
                .foregroundColor(AppTheme.secondaryText)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("推荐标签")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.primaryText)

            EmptyStateView(
                title: "热门标签待接入",
                message: "Pixiv 推荐标签接口迁移后会显示在这里。",
                systemImage: "number"
            )
            .frame(maxWidth: .infinity, minHeight: 170)
        }
    }

    private func addCurrentQuery() {
        let tag = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        history.removeAll { $0 == tag }
        history.insert(tag, at: 0)
        if history.count > 20 {
            history.removeLast()
        }
    }
}