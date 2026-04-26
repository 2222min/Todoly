import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: TodoStore

    @State private var query = ""
    @State private var searchResults: [Todo] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var recent: [String] = {
        UserDefaults.standard.stringArray(forKey: "todoly_recent_searches") ?? ["보고서", "장보기", "운동"]
    }()
    @FocusState private var isSearchFocused: Bool

    private var showResults: Bool { !query.isEmpty && searchTask == nil || !searchResults.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar
            Divider().foregroundColor(.txt3.opacity(0.2)).padding(.horizontal, 20)
            resultBody
        }
        .background(Color.brandBg)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isSearchFocused = true
            }
        }
        .onChange(of: query) { _, newValue in
            refreshSearch(for: newValue)
        }
        .onChange(of: store.incomplete.count) { _, _ in
            refreshSearch(for: query, debounce: false)
        }
        .onChange(of: store.completed.count) { _, _ in
            refreshSearch(for: query, debounce: false)
        }
    }

    // MARK: - Result Body

    private var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var resultBody: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isQueryEmpty {
                    recentSearchSection.padding(.top, 20)
                }
                if !isQueryEmpty {
                    searchResultSection.padding(.top, 20)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.txt1)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text("검색")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.txt1)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.txt3)
                .font(.system(size: 15))
            TextField("할 일, 메모, 카테고리 검색", text: $query)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.txt1)
                .focused($isSearchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit { saveRecent(query) }
            if !query.isEmpty {
                Button {
                    query = ""
                    searchResults = []
                    searchTask?.cancel()
                    searchTask = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.txt3)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    // MARK: - Recent Search

    private var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !recent.isEmpty {
                HStack {
                    Text("최근 검색어")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.txt2)
                    Spacer()
                    Button {
                        recent.removeAll()
                        saveRecentToDefaults()
                    } label: {
                        Text("전체 삭제")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.txt3)
                    }
                }

                FlowLayout(spacing: 8) {
                    ForEach(recent, id: \.self) { kw in
                        recentChip(kw)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 28))
                        .foregroundColor(.txt3.opacity(0.5))
                    Text("최근 검색 기록이 없습니다")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.txt3)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            }
        }
        .padding(.horizontal, 20)
    }

    private func recentChip(_ keyword: String) -> some View {
        HStack(spacing: 5) {
            Text(keyword)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.txt2)
            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    recent.removeAll { $0 == keyword }
                    saveRecentToDefaults()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.txt3)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.08))
        .clipShape(Capsule())
        .onTapGesture {
            query = keyword
            refreshSearch(for: keyword, debounce: false)
            saveRecent(keyword)
        }
    }


    // MARK: - Search Results

    private var searchResultSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("검색 결과")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.txt2)
                Text("\(searchResults.count)건")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.accent1)
            }

            if searchResults.isEmpty {
                emptyResultView
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(searchResults, id: \.id) { todo in
                        TaskCardView(todo: todo)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var emptyResultView: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.txt3.opacity(0.5))
            Text("'\(query)'에 대한 결과가 없습니다")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.txt3)
            Text("다른 검색어를 입력해 보세요")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.txt3.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Helpers

    private func saveRecent(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        recent.removeAll { $0 == trimmed }
        recent.insert(trimmed, at: 0)
        if recent.count > 10 { recent = Array(recent.prefix(10)) }
        saveRecentToDefaults()
    }

    private func saveRecentToDefaults() {
        UserDefaults.standard.set(recent, forKey: "todoly_recent_searches")
    }

    private func refreshSearch(for value: String, debounce: Bool = true) {
        searchTask?.cancel()
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            searchResults = []
            searchTask = nil
            return
        }
        if debounce {
            searchTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else { return }
                searchResults = TodoFilterLogic.search(
                    query: trimmed,
                    in: store.incomplete + store.completed
                )
                searchTask = nil
            }
        } else {
            searchResults = TodoFilterLogic.search(
                query: trimmed,
                in: store.incomplete + store.completed
            )
            searchTask = nil
        }
    }
}

// MARK: - FlowLayout (태그 줄바꿈 레이아웃)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (origins: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (origins, CGSize(width: maxWidth, height: y + rowHeight))
    }
}

// MARK: - Preview

#Preview("SearchView") {
    SearchView()
        .environmentObject(TodoStore(useSeedData: true))
}
