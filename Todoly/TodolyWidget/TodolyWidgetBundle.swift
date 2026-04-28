import WidgetKit
import SwiftUI

@main
struct TodolyWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        TodolyAlarmLiveActivity()
    }
}
