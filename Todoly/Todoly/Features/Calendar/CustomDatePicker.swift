import SwiftUI

struct CustomDatePicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    @State private var displayMonth: Date = Date()
    @State private var selectedHour = 9
    @State private var selectedMinute = 0
    @State private var isAM = true

    private let quickPresets = [
        ("오전 9시", 9, 0, true),
        ("오후 12시", 12, 0, false),
        ("오후 6시", 6, 0, false),
        ("오후 9시", 9, 0, false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 헤더
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium)).foregroundColor(.txt1)
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Text("날짜 및 시간 선택")
                    .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                Button { confirm() } label: {
                    Text("완료").font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(.accent1)
                }
                .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Color.brandBg)

            ScrollView {
                VStack(spacing: 24) {
                    calendarSection
                    Divider().padding(.horizontal, 24)
                    timeSection
                    quickPresetSection
                    confirmButton
                }.padding(.vertical, 16)
            }
        }
        .background(Color.brandBg)
        .onAppear { loadFromDate() }
    }

    // MARK: - Calendar Section

    private var calendarSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left").foregroundColor(.txt1) }
                Spacer()
                Text(CalendarDateLogic.monthYearString(for: displayMonth))
                    .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.txt1)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right").foregroundColor(.txt1) }
            }.padding(.horizontal, 24)

            HStack {
                ForEach(["일","월","화","수","목","금","토"], id: \.self) { d in
                    Text(d).font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(d == "일" ? .priHigh : (d == "토" ? .priLow : .txt2))
                        .frame(maxWidth: .infinity)
                }
            }.padding(.horizontal, 16)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { day in
                    if day == 0 {
                        Text("").frame(height: 40)
                    } else {
                        let date = CalendarDateLogic.makeDate(day: day, in: displayMonth)
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let isToday = Calendar.current.isDateInToday(date)

                        Button {
                            selectedDate = combineDateTime(date: date)
                        } label: {
                            Text("\(day)")
                                .font(.system(size: 15, weight: isSelected ? .bold : .medium, design: .rounded))
                                .foregroundColor(isSelected ? .white : (isToday ? .accent1 : .txt1))
                                .frame(width: 40, height: 40)
                                .background {
                                    if isSelected {
                                        Circle().fill(
                                            LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                    } else if isToday {
                                        Circle().fill(Color.accent1.opacity(0.1))
                                    }
                                }
                                .clipShape(Circle())
                        }
                        .id(day)
                    }
                }
            }.padding(.horizontal, 16)
        }
    }

    // MARK: - Time Section

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⏰ 시간 선택")
                .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.txt1)
                .padding(.horizontal, 24)
            HStack(spacing: 16) {
                Spacer()
                Picker("Hour", selection: $selectedHour) {
                    ForEach(1...12, id: \.self) { h in
                        Text(String(format: "%02d", h))
                            .foregroundColor(.txt1)
                            .tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 150)
                .clipped()

                Text(":").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(.txt1)

                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { m in
                        Text(String(format: "%02d", m))
                            .foregroundColor(.txt1)
                            .tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 150)
                .clipped()

                VStack(spacing: 8) {
                    amPmButton("AM", isSelected: isAM) { isAM = true }
                    amPmButton("PM", isSelected: !isAM) { isAM = false }
                }
                Spacer()
            }
        }
    }

    private func amPmButton(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : .txt2)
                .frame(width: 56, height: 36)
                .background(isSelected ? Color.accent1 : Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Quick Presets

    private var quickPresetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("빠른 선택")
                .font(.system(size: 13, weight: .medium, design: .rounded)).foregroundColor(.txt3)
                .padding(.horizontal, 24)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPresets, id: \.0) { preset in
                        let match = selectedHour == preset.1 && selectedMinute == preset.2 && isAM == preset.3
                        Button {
                            selectedHour = preset.1; selectedMinute = preset.2; isAM = preset.3
                        } label: {
                            Text(preset.0)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(match ? .white : .txt2)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(match ? Color.txt1 : Color.gray.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }.padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Confirm

    private var confirmButton: some View {
        Button { confirm() } label: {
            Text(confirmText)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(LinearGradient(colors: [.accent1, Color(hex: "FF6B6B")],
                                           startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .accent1.opacity(0.3), radius: 12, y: 4)
        }
        .buttonStyle(SoftPressStyle())
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private var confirmText: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M월 d일"
        let ampm = isAM ? "오전" : "오후"
        return "\(df.string(from: selectedDate)) \(ampm) \(selectedHour):\(String(format: "%02d", selectedMinute)) 선택 ✨"
    }

    private func changeMonth(_ delta: Int) {
        displayMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayMonth) ?? displayMonth
    }

    private func daysInMonth() -> [Int] {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: displayMonth)!
        let firstWeekday = cal.component(.weekday, from: cal.date(from: cal.dateComponents([.year, .month], from: displayMonth))!) - 1
        return Array(repeating: 0, count: firstWeekday) + Array(range)
    }

    private func loadFromDate() {
        let cal = Calendar.current
        displayMonth = selectedDate
        var hour = cal.component(.hour, from: selectedDate)
        selectedMinute = cal.component(.minute, from: selectedDate)
        isAM = hour < 12
        if hour == 0 { hour = 12 }
        else if hour > 12 { hour -= 12 }
        selectedHour = hour
    }

    /// 날짜 선택 시 현재 picker 시간 정보 유지
    private func combineDateTime(date: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: date)
        var hour = selectedHour
        if !isAM && hour != 12 { hour += 12 }
        if isAM && hour == 12 { hour = 0 }
        comps.hour = hour
        comps.minute = selectedMinute
        return cal.date(from: comps) ?? date
    }

    private func confirm() {
        var hour = selectedHour
        if !isAM && hour != 12 { hour += 12 }
        if isAM && hour == 12 { hour = 0 }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        comps.hour = hour; comps.minute = selectedMinute
        selectedDate = Calendar.current.date(from: comps) ?? selectedDate
        dismiss()
    }
}

// MARK: - Preview

#Preview("CustomDatePicker") {
    CustomDatePicker(selectedDate: .constant(Date()))
}
