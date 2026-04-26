import Foundation

/// 순수 함수: 카테고리 상태 변환 로직
enum CategoryMutationLogic {

    struct UpdateResult {
        let categories: [TodoCategory]
        let incomplete: [Todo]
        let completed: [Todo]
    }

    /// 카테고리 업데이트 — 연관된 할 일의 카테고리 정보도 함께 갱신
    static func updateCategory(
        id: String,
        name: String,
        color: String,
        emoji: String,
        categories: [TodoCategory],
        incomplete: [Todo],
        completed: [Todo]
    ) -> UpdateResult {
        var cats = categories
        var inc = incomplete
        var comp = completed

        guard let i = cats.firstIndex(where: { $0.id == id }) else {
            return UpdateResult(categories: cats, incomplete: inc, completed: comp)
        }

        let oldName = cats[i].name
        cats[i].name = name
        cats[i].color = color
        cats[i].emoji = emoji

        for j in inc.indices where inc[j].categoryName == oldName {
            inc[j].categoryName = name
            inc[j].categoryColor = color
        }
        for j in comp.indices where comp[j].categoryName == oldName {
            comp[j].categoryName = name
            comp[j].categoryColor = color
        }

        return UpdateResult(categories: cats, incomplete: inc, completed: comp)
    }

    /// 카테고리 삭제 — 연관된 할 일의 카테고리를 nil로 초기화
    static func deleteCategory(
        id: String,
        categories: [TodoCategory],
        incomplete: [Todo],
        completed: [Todo]
    ) -> UpdateResult {
        var cats = categories
        var inc = incomplete
        var comp = completed

        guard let cat = cats.first(where: { $0.id == id }) else {
            return UpdateResult(categories: cats, incomplete: inc, completed: comp)
        }

        cats.removeAll { $0.id == id }

        for j in inc.indices where inc[j].categoryName == cat.name {
            inc[j].categoryName = nil
            inc[j].categoryColor = nil
        }
        for j in comp.indices where comp[j].categoryName == cat.name {
            comp[j].categoryName = nil
            comp[j].categoryColor = nil
        }

        return UpdateResult(categories: cats, incomplete: inc, completed: comp)
    }
}
