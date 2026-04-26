import XCTest
@testable import Todoly

final class NotificationServiceTests: XCTestCase {

    // MARK: - Reminder Subtitle (순수 함수 테스트)

    func testReminderSubtitleAtTime() {
        let svc = NotificationService.shared
        // 0분 = 마감 시간
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 0), "마감 시간입니다!")
    }

    func testReminderSubtitleMinutes() {
        let svc = NotificationService.shared
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 5), "5분 후 마감")
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 30), "30분 후 마감")
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 59), "59분 후 마감")
    }

    func testReminderSubtitleHours() {
        let svc = NotificationService.shared
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 60), "1시간 후 마감")
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 120), "2시간 후 마감")
    }

    func testReminderSubtitleDays() {
        let svc = NotificationService.shared
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 1440), "1일 후 마감")
        XCTAssertEqual(svc.testReminderSubtitle(minutesBefore: 2880), "2일 후 마감")
    }

    // MARK: - Notification Content 생성 테스트

    func testBuildNotificationContent() {
        let svc = NotificationService.shared
        let content = svc.testBuildContent(title: "테스트 할 일", subtitle: "5분 후 마감", todoId: "test-123")
        XCTAssertEqual(content.title, "Todoly 📋")
        XCTAssertEqual(content.body, "테스트 할 일")
        XCTAssertEqual(content.subtitle, "5분 후 마감")
        XCTAssertEqual(content.userInfo["todoId"] as? String, "test-123")
        XCTAssertNotNil(content.sound)
    }

    // MARK: - onAlarmTriggered 콜백 테스트

    func testOnAlarmTriggeredCallback() {
        let svc = NotificationService.shared
        var receivedTitle: String?
        var receivedSubtitle: String?

        svc.onAlarmTriggered = { title, subtitle in
            receivedTitle = title
            receivedSubtitle = subtitle
        }

        svc.onAlarmTriggered?("보고서 제출", "마감 시간입니다!")

        XCTAssertEqual(receivedTitle, "보고서 제출")
        XCTAssertEqual(receivedSubtitle, "마감 시간입니다!")

        // cleanup
        svc.onAlarmTriggered = nil
    }
}
