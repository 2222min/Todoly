import XCTest
@testable import Todoly

final class SharedDefaultsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // 테스트 전 App Group UserDefaults 초기화
        let defaults = SharedDefaults.shared
        defaults.removeObject(forKey: SharedDefaults.incompleteKey)
        defaults.removeObject(forKey: SharedDefaults.completedKey)
        defaults.removeObject(forKey: SharedDefaults.trashKey)
        defaults.removeObject(forKey: SharedDefaults.categoriesKey)
        defaults.removeObject(forKey: SharedDefaults.hasLaunchedKey)
        defaults.removeObject(forKey: "todoly_migrated_to_group")
    }

    // MARK: - Save & Load Round-Trip

    func testSaveAndLoadIncomplete() {
        let todos = [
            Todo(title: "테스트1", priority: .high),
            Todo(title: "테스트2", priority: .low),
        ]
        SharedDefaults.saveAll(incomplete: todos, completed: [], trash: [], categories: [])

        let loaded = SharedDefaults.loadIncomplete()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].title, "테스트1")
        XCTAssertEqual(loaded[1].title, "테스트2")
        XCTAssertEqual(loaded[0].priority, .high)
    }

    func testSaveAndLoadCompleted() {
        let todos = [
            Todo(title: "완료됨", isCompleted: true, completedAt: .now),
        ]
        SharedDefaults.saveAll(incomplete: [], completed: todos, trash: [], categories: [])

        let loaded = SharedDefaults.loadCompleted()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertTrue(loaded[0].isCompleted)
    }

    func testSaveAndLoadTrash() {
        let todos = [
            Todo(title: "삭제됨", isDeleted: true, deletedAt: .now),
        ]
        SharedDefaults.saveAll(incomplete: [], completed: [], trash: todos, categories: [])

        let loaded = SharedDefaults.loadTrash()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertTrue(loaded[0].isDeleted)
    }

    func testSaveAndLoadCategories() {
        let cats = [
            TodoCategory(name: "테스트", color: "FF0000", emoji: "🧪"),
        ]
        SharedDefaults.saveAll(incomplete: [], completed: [], trash: [], categories: cats)

        let loaded = SharedDefaults.loadCategories()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "테스트")
        XCTAssertEqual(loaded[0].emoji, "🧪")
    }

    func testLoadCategoriesReturnsDefaultsWhenEmpty() {
        // 아무것도 저장하지 않은 상태
        let loaded = SharedDefaults.loadCategories()
        XCTAssertEqual(loaded.count, TodoCategory.defaults.count)
    }

    func testLoadIncompleteReturnsEmptyWhenNoData() {
        let loaded = SharedDefaults.loadIncomplete()
        XCTAssertTrue(loaded.isEmpty)
    }

    // MARK: - Migration

    func testMigrateFromStandardToGroup() {
        // standard에 데이터 저장
        let todos = [Todo(title: "마이그레이션 테스트", priority: .medium)]
        let data = try! JSONEncoder().encode(todos)
        UserDefaults.standard.set(data, forKey: SharedDefaults.incompleteKey)
        UserDefaults.standard.set(true, forKey: SharedDefaults.hasLaunchedKey)

        // 마이그레이션 실행
        SharedDefaults.migrateIfNeeded()

        // App Group에서 읽기
        let loaded = SharedDefaults.loadIncomplete()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].title, "마이그레이션 테스트")
        XCTAssertTrue(SharedDefaults.shared.bool(forKey: SharedDefaults.hasLaunchedKey))

        // cleanup
        UserDefaults.standard.removeObject(forKey: SharedDefaults.incompleteKey)
        UserDefaults.standard.removeObject(forKey: SharedDefaults.hasLaunchedKey)
    }

    func testMigrateOnlyRunsOnce() {
        let todos = [Todo(title: "첫번째", priority: .high)]
        let data = try! JSONEncoder().encode(todos)
        UserDefaults.standard.set(data, forKey: SharedDefaults.incompleteKey)

        SharedDefaults.migrateIfNeeded()

        // standard 데이터 변경
        let todos2 = [Todo(title: "두번째", priority: .low)]
        let data2 = try! JSONEncoder().encode(todos2)
        UserDefaults.standard.set(data2, forKey: SharedDefaults.incompleteKey)

        // 두 번째 마이그레이션은 실행되지 않아야 함
        SharedDefaults.migrateIfNeeded()

        let loaded = SharedDefaults.loadIncomplete()
        XCTAssertEqual(loaded[0].title, "첫번째") // 두번째가 아님

        // cleanup
        UserDefaults.standard.removeObject(forKey: SharedDefaults.incompleteKey)
    }

    // MARK: - Period Task Round-Trip

    func testSaveAndLoadPeriodTask() {
        let cal = Calendar.current
        let todo = Todo(
            title: "매일 운동",
            priority: .medium,
            startDate: .now,
            endDate: cal.date(byAdding: .day, value: 7, to: .now),
            dailyCompletions: [Todo.dateKey(for: .now): .now]
        )
        SharedDefaults.saveAll(incomplete: [todo], completed: [], trash: [], categories: [])

        let loaded = SharedDefaults.loadIncomplete()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertTrue(loaded[0].isPeriodTask)
        XCTAssertTrue(loaded[0].isCompletedOn(.now))
        XCTAssertEqual(loaded[0].totalDays, 8)
    }
}
