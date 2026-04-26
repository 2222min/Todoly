import XCTest
@testable import Todoly

final class TodoAlarmAttributesTests: XCTestCase {

    func testAttributesCreation() {
        let attrs = TodoAlarmAttributes(
            todoTitle: "보고서 제출",
            subtitle: "마감 시간입니다!",
            todoId: "test-id-123"
        )
        XCTAssertEqual(attrs.todoTitle, "보고서 제출")
        XCTAssertEqual(attrs.subtitle, "마감 시간입니다!")
        XCTAssertEqual(attrs.todoId, "test-id-123")
    }

    func testContentStateCreation() {
        let state = TodoAlarmAttributes.ContentState(
            remainingTime: "5분 경과",
            isRinging: true
        )
        XCTAssertEqual(state.remainingTime, "5분 경과")
        XCTAssertTrue(state.isRinging)
    }

    func testContentStateEquality() {
        let state1 = TodoAlarmAttributes.ContentState(remainingTime: "지금", isRinging: true)
        let state2 = TodoAlarmAttributes.ContentState(remainingTime: "지금", isRinging: true)
        let state3 = TodoAlarmAttributes.ContentState(remainingTime: "완료", isRinging: false)
        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }

    func testContentStateCodable() throws {
        let state = TodoAlarmAttributes.ContentState(remainingTime: "3분 경과", isRinging: true)
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(TodoAlarmAttributes.ContentState.self, from: data)
        XCTAssertEqual(decoded.remainingTime, "3분 경과")
        XCTAssertTrue(decoded.isRinging)
    }
}
