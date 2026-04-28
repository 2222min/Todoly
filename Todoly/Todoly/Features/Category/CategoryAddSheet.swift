import SwiftUI

struct CategoryAddSheet: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var selectedColor = "FF6B6B"
    @State private var selectedEmoji = "👤"
    var editingCategory: TodoCategory? = nil
    @FocusState private var isFocused: Bool

    private let colorOptions = ["FF6B6B","FFAB5E","FFC847","6DD5C8","5B9BF5","5A8AF2","A78BFA","B0B0B0"]
    private let emojiSections: [(String, [String])] = [
        ("일상 & 생활", ["👤","🏠","🛏️","🧹","🧺","🍳","☕","🪴"]),
        ("업무 & 학습", ["💼","💻","📊","📝","📚","🎓","📐","🗂️"]),
        ("건강 & 운동", ["🏃","🧘","🏋️","🚴","🏊","💊","🩺","🥗"]),
        ("취미 & 여가", ["🎮","🎵","🎨","📷","🎬","📖","✈️","⛺"]),
        ("쇼핑 & 금융", ["🛒","💰","💳","🎁","📦","🏦","🧾","🛍️"]),
        ("소셜 & 관계", ["❤️","👨‍👩‍👧","🤝","🎂","📞","✉️","🐶","🌸"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더 (버튼 제거 → 하단 CTA)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold)).foregroundColor(.txt1)
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text(editingCategory != nil ? "🏷 카테고리 수정" : "🏷 새 카테고리")
                    .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Color.brandBg)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    previewCard
                    nameField
                    colorPicker
                    emojiPicker
                }.padding(24)
            }

            // 하단 CTA 버튼
            Button(action: save) {
                Text(editingCategory != nil ? "저장하기" : "추가하기")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(name.isEmpty ? Color.gray.opacity(0.4) : Color.accent1)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(name.isEmpty)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.brandBg)
        }
        .background(Color.brandBg)
        .onTapGesture { isFocused = false }
        .onAppear {
            if let cat = editingCategory {
                name = cat.name; selectedColor = cat.color; selectedEmoji = cat.emoji
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("카테고리 이름").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(.txt2)
            TextField("예: 운동, 공부, 취미...", text: $name, prompt: Text("예: 운동, 공부, 취미...").foregroundColor(.txt2))
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.txt1)
                .focused($isFocused)
                .padding(16).background(Color.gray.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎨 색상 선택").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(.txt2)
            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { hex in
                    Circle().fill(Color(hex: hex)).frame(width: 36, height: 36)
                        .overlay(Circle().stroke(selectedColor == hex ? Color.txt1 : .clear, lineWidth: 3))
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                        .onTapGesture { selectedColor = hex }
                }
            }
        }
    }

    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("😊 이모지 선택").font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(.txt2)
            ForEach(emojiSections, id: \.0) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.0)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.txt3)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                        ForEach(section.1, id: \.self) { emoji in
                            Text(emoji).font(.system(size: 24)).frame(width: 40, height: 40)
                                .background(selectedEmoji == emoji ? Color.gray.opacity(0.1) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selectedEmoji == emoji ? Color.txt1 : .clear, lineWidth: 2))
                                .onTapGesture { selectedEmoji = emoji }
                        }
                    }
                }
            }
        }
    }

    private var previewCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: selectedColor).opacity(0.2)).frame(width: 44, height: 44)
                Text(selectedEmoji).font(.system(size: 22))
            }
            Text(name.isEmpty ? "미리보기" : name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(name.isEmpty ? .txt3 : .txt1)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.04), radius: 16, y: 6)
    }

    private func save() {
        if let cat = editingCategory {
            store.updateCategory(id: cat.id, name: name, color: selectedColor, emoji: selectedEmoji)
        } else {
            store.addCategory(name: name, color: selectedColor, emoji: selectedEmoji)
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview("CategoryAddSheet") {
    CategoryAddSheet()
        .environmentObject(TodoStore())
}
