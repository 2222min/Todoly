---
inclusion: auto
---

# ⚡ SwiftUI 성능 패턴 & 검색 구현 가이드

이 세션에서 발견된 SwiftUI 성능 이슈와 해결 패턴을 정리합니다.
코드를 생성하거나 수정할 때 항상 참고합니다.

---

## 1. Debounce 패턴 — `Just(query)` 사용 금지

### ❌ 잘못된 패턴
```swift
.onReceive(
    Just(query)
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
) { value in
    debouncedQuery = value
}
```
- `Just`는 단일 값 publisher → body 재평가 시마다 새 publisher 생성
- debounce가 매번 리셋되어 사실상 무효화
- 타이밍 이슈로 값이 업데이트 안 되는 경우 발생

### ✅ 올바른 패턴: `onChange` + `Task.sleep`
```swift
@State private var searchTask: Task<Void, Never>?

.onChange(of: query) { _, newValue in
    searchTask?.cancel()
    searchTask = Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(200))
        guard !Task.isCancelled else { return }
        // 검색 실행
    }
}
```
- 이전 Task를 cancel하고 새로 생성 → 확실한 debounce
- `Combine` import 불필요

---

## 2. 검색 결과 캐싱 — `@State`로 분리

### ❌ 잘못된 패턴
```swift
private var searchResultSection: some View {
    let results = TodoFilterLogic.search(query: q, in: store.incomplete + store.completed)
    // ...
}
```
- body 재평가 시마다 배열 합치기 + 필터링 반복
- 키보드 입력마다 불필요한 연산 발생 → 버벅임

### ✅ 올바른 패턴
```swift
@State private var searchResults: [Todo] = []

// debounce 완료 시점에 한 번만 계산
searchResults = TodoFilterLogic.search(query: trimmed, in: store.incomplete + store.completed)
```
- 검색 결과를 `@State`로 캐싱하여 body 재평가 시 재계산 방지

### ⚠️ 주의: `@State` 캐싱 시 store 변경 감지 필수
`@State`로 캐싱하면 store 데이터가 변경되어도 자동 갱신 안 됨.
체크박스 탭 등으로 store가 변경될 때 검색 결과도 갱신해야 함:
```swift
.onChange(of: store.incomplete.count) { _, _ in
    refreshSearch(for: query, debounce: false)  // 즉시 갱신
}
.onChange(of: store.completed.count) { _, _ in
    refreshSearch(for: query, debounce: false)
}
```

---

## 3. ScrollView 교체 비용 — `if/else`로 ScrollView 분기 금지

### ❌ 잘못된 패턴
```swift
if condition {
    ScrollView { sectionA }
} else {
    ScrollView { sectionB }
}
```
- 조건 변경 시 ScrollView 자체가 파괴 → 재생성
- 내부 LazyVStack + 모든 자식 뷰가 처음부터 초기화
- 첫 전환 시 눈에 띄는 지연 발생

### ✅ 올바른 패턴: 하나의 ScrollView, 내부 콘텐츠만 전환
```swift
ScrollView {
    VStack(spacing: 0) {
        if condition { sectionA }
        if !condition { sectionB }
    }
}
```
- ScrollView 컨테이너는 유지, 내부만 교체
- 뷰 컨테이너 재생성 비용 제거

---

## 4. 키보드 포커스 — `onAppear` 타이밍

### ❌ 잘못된 패턴
```swift
.onAppear { isSearchFocused = true }
```
- SwiftUI 렌더링 완료 전에 호출되어 무시될 수 있음

### ✅ 올바른 패턴
```swift
.onAppear {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        isSearchFocused = true
    }
}
```
- 렌더링 완료 후 포커스 설정 → 키보드가 확실히 올라옴

---

## 5. TextField 성능 — 자동완성/자동대문자 비활성화

검색 입력 필드에는 iOS 자동완성/자동대문자 처리를 비활성화하여 오버헤드 제거:
```swift
TextField("검색", text: $query)
    .autocorrectionDisabled()
    .textInputAutocapitalization(.never)
```

---

## 6. FlowLayout — 태그/칩 줄바꿈 레이아웃

최근 검색어 칩 등 가변 너비 아이템의 줄바꿈이 필요할 때 `FlowLayout` (custom `Layout` protocol) 사용.
`SearchView.swift`에 구현되어 있으며, 필요 시 `Core/Components/`로 추출 가능.

---

## 7. 터치 영역 겹침 — `contentShape(.scale())` 주의

### ❌ 잘못된 패턴
```swift
.contentShape(Circle().scale(1.8))
```
- 터치 영역이 시각적 요소보다 훨씬 넓어져 인접 요소와 겹침
- 특히 리스트에서 섹션 헤더 탭이 바로 아래 첫 번째 아이템의 버튼으로 전달되는 버그 유발
- 완료됨 섹션 헤더를 탭했는데 첫 번째 완료 아이템의 체크박스가 눌리는 현상 발생

### ✅ 올바른 패턴
```swift
// 1. contentShape 크기를 적절히 제한
.contentShape(Circle())  // scale 없이 frame 크기만큼만

// 2. 섹션 헤더에 contentShape(Rectangle())를 추가하여 터치 이벤트 차단
HStack { Text("완료됨"); Spacer() }
    .padding(.vertical, 8)
    .contentShape(Rectangle())  // 헤더 영역의 탭이 아래로 전파되지 않도록 차단
```

### 핵심 원칙
- `contentShape`의 `scale()`은 1.0 이하로만 사용하거나 아예 사용하지 않는다
- 리스트에서 섹션 헤더와 첫 번째 아이템 사이에 충분한 간격(최소 16pt)을 확보한다
- 섹션 헤더에는 `contentShape(Rectangle())`를 추가하여 터치 이벤트 경계를 명확히 한다

---

## 8. TextEditor 텍스트 색상 — 명시적 foregroundColor 필수

### ❌ 잘못된 패턴
```swift
TextEditor(text: $memo)
    .scrollContentBackground(.hidden)
    .background(Color.gray.opacity(0.06))
```
- `scrollContentBackground(.hidden)`으로 기본 배경을 제거하면 텍스트 색상도 영향받을 수 있음
- 밝은 배경 위에서 텍스트가 보이지 않는 현상 발생

### ✅ 올바른 패턴
```swift
TextEditor(text: $memo)
    .foregroundColor(.txt1)  // 반드시 명시
    .scrollContentBackground(.hidden)
    .background(Color.gray.opacity(0.06))
```
- `TextEditor`에는 항상 `.foregroundColor()`를 명시적으로 지정한다
- `TextField`와 달리 `TextEditor`는 기본 색상이 환경에 따라 달라질 수 있다

---

## 9. 섹션 간 여백 설계 — 탭바와의 간격

### 원칙
- 스크롤 콘텐츠의 마지막 섹션은 탭바와 충분한 간격을 확보해야 한다
- 최소 `.padding(.bottom, 24)` 이상을 마지막 섹션에 적용
- 섹션 간 구분이 필요한 경우 `.padding(.top, 8)` 이상으로 시각적 여유를 준다
- 완료됨 같은 보조 섹션은 주요 섹션과 더 넓은 간격으로 구분한다

---

## 10. 검색 화면 구현 체크리스트

검색 화면을 구현하거나 수정할 때 확인:

| # | 항목 |
|---|------|
| 1 | debounce가 `onChange` + `Task.sleep` 패턴인가? |
| 2 | 검색 결과가 `@State`로 캐싱되어 있는가? |
| 3 | store 변경 시 검색 결과가 즉시 갱신되는가? |
| 4 | ScrollView가 조건부로 교체되지 않는가? |
| 5 | 키보드 포커스가 약간의 딜레이 후 설정되는가? |
| 6 | autocorrection/autocapitalization이 비활성화되어 있는가? |
| 7 | 최근 검색어가 UserDefaults에 영속화되는가? |


---

## 11. 탭 전환 깜빡임 방지 — opacity 패턴 + 애니메이션 전파 차단

### ❌ 잘못된 패턴
```swift
// 1. switch로 뷰 교체 → 뷰 파괴/재생성으로 깜빡임
Group {
    switch tab {
    case .tasks: MainListView()
    case .calendar: CalendarView()
    }
}

// 2. withAnimation이 탭 전환에 전파 → 전체 화면 깜빡임
.onTapGesture {
    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
        selectedTab = tab
    }
}
```

### ✅ 올바른 패턴
```swift
// 1. 모든 탭 뷰를 미리 생성, opacity로 전환
ZStack {
    MainListView().opacity(tab == .tasks ? 1 : 0)
    CalendarView().opacity(tab == .calendar ? 1 : 0)
}
.animation(.none, value: tab)

// 2. 탭 전환은 애니메이션 없이 즉시 처리
.onTapGesture { selectedTab = tab }
```
- 뷰 파괴/재생성 비용 제거
- `withAnimation`이 상위 뷰까지 전파되는 문제 차단
- 탭 아이콘 애니메이션이 필요하면 아이콘 뷰 내부에서만 로컬 애니메이션 적용

---

## 12. iOS 26 Liquid Glass 자동 적용 — NavigationStack toolbar 주의

### 문제
iOS 26에서 `NavigationStack`의 `.toolbar` 아이템에 liquid glass 스타일이 자동 적용됨.
`.toolbarBackgroundVisibility(.visible)` + `.toolbarBackground(Color.white)`로는 toolbar 아이템 자체의 glass를 제거할 수 없음.

### ✅ 해결: NavigationStack + toolbar 대신 커스텀 헤더 사용
```swift
// NavigationStack + toolbar 제거하고 커스텀 헤더로 교체
VStack(spacing: 0) {
    HStack {
        Button { dismiss() } label: {
            Image(systemName: "xmark").foregroundColor(.txt2).frame(width: 40, height: 40)
        }
        Spacer()
        Text("제목").font(.system(size: 17, weight: .semibold, design: .rounded))
        Spacer()
        Button { save() } label: {
            Text("저장").font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 6)
                .background(Color.txt1).clipShape(Capsule())
        }
    }
    .padding(.horizontal, 16).padding(.vertical, 10)
    .background(Color.white)

    ScrollView { /* content */ }
}
.navigationBarHidden(true)
```

### 적용 대상
- Liquid glass를 탭바에만 적용하고 싶으면, 나머지 모든 화면에서 NavigationStack toolbar를 커스텀 헤더로 교체
- `BottomNavBar`의 `glassEffect`만 유지

---

## 13. TextField placeholder 가시성 — prompt 파라미터 사용

### ❌ 잘못된 패턴
```swift
TextField("placeholder text", text: $value)
```
- 기본 placeholder 색상이 밝은 배경에서 거의 안 보일 수 있음

### ✅ 올바른 패턴
```swift
TextField("placeholder text", text: $value, prompt: Text("placeholder text").foregroundColor(.txt2))
    .foregroundColor(.txt1)
```
- `prompt:` 파라미터로 placeholder 색상을 명시적으로 지정
- 입력 텍스트 색상도 `.foregroundColor(.txt1)`로 명시

---

## 14. Empty State 가운데 정렬 — `.frame(maxWidth: .infinity)` 필수

### 문제
빈 상태 메시지가 `VStack(alignment: .leading)` 안에 배치되면 왼쪽으로 밀림.
`multilineTextAlignment(.center)`만으로는 텍스트 블록 자체의 위치가 바뀌지 않음.

### ❌ 잘못된 패턴
```swift
ScrollView {
    VStack(alignment: .leading, spacing: 12) {
        // 리스트 아이템들은 .leading이 맞지만...
        emptyMessage("이 날은 할 일이 없어요 🎉")  // ← 왼쪽으로 밀림
    }
}

private func emptyMessage(_ text: String) -> some View {
    VStack {
        Text(text)
            .multilineTextAlignment(.center)  // 텍스트 정렬만 가운데, 뷰 자체는 왼쪽
    }
}
```

### ✅ 올바른 패턴
```swift
private func emptyMessage(_ text: String) -> some View {
    VStack {
        Text(text)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)  // 부모 VStack의 alignment 무시하고 전체 너비 차지
}
```

### 핵심 원칙
- 가운데 정렬이 필요한 뷰(빈 상태, 로딩 인디케이터, 안내 메시지 등)는 `.frame(maxWidth: .infinity)`를 반드시 추가
- 부모 `VStack(alignment: .leading)`이 자식 뷰의 정렬을 강제하므로, 자식 뷰에서 명시적으로 전체 너비를 잡아야 함
- `multilineTextAlignment`은 텍스트 줄바꿈 정렬만 제어하고, 뷰 자체의 위치에는 영향 없음

---

## 15. Wheel Picker 텍스트 가시성 & 조작성

### 문제
- `.wheel` 피커의 아이템에 `.foregroundColor`를 지정하지 않으면 텍스트가 안 보일 수 있음
- 피커 frame이 너무 작으면 (height: 120 이하) 스크롤 조작이 어려움

### ✅ 올바른 패턴
```swift
Picker("Minute", selection: $selectedMinute) {
    ForEach(0..<60, id: \.self) { m in
        Text(String(format: "%02d", m))
            .foregroundColor(.txt1)  // 반드시 명시
            .tag(m)
    }
}
.pickerStyle(.wheel)
.frame(width: 80, height: 150)  // 최소 150 높이 권장
.clipped()
```


---

## 16. glassEffect + Button 제스처 충돌 — interactive() 사용 금지

### 문제
`glassEffect(.regular.interactive())` 또는 `glassEffect(.regular.interactive)` 사용 시 글래스 이펙트가 터치 제스처를 가로채서 `Button`의 탭 이벤트가 씹힘. 몇 번 눌리다가 안 눌리는 간헐적 현상 발생.

### ❌ 잘못된 패턴
```swift
Button { action() } label: {
    Circle().frame(width: 42, height: 42)
        .glassEffect(.regular.interactive(), in: .circle)  // 제스처 충돌!
}
```

### ✅ 올바른 패턴
```swift
// 1. interactive() 제거 — 비주얼만 적용
.glassEffect(.regular, in: .circle)

// 2. 그래도 안 되면 Button 대신 onTapGesture + contentShape 사용
VStack { /* 탭 아이콘 */ }
    .frame(width: 72, height: 60)
    .contentShape(Rectangle())
    .onTapGesture { selectedTab = tab }
```

### 핵심 원칙
- `glassEffect`의 `interactive()`는 글래스 자체가 터치를 처리하게 만듦 → Button과 충돌
- 탭바처럼 버튼이 필요한 곳에서는 `.regular`만 사용하고 interactive 제거
- 배경에만 글래스를 적용하고, 개별 버튼에는 글래스를 넣지 않는 것이 안전

---

## 17. 캘린더 체크박스 토글 애니메이션 — stagger + withAnimation 충돌

### 문제
캘린더에서 체크박스를 눌러 완료 처리할 때, `.animation(..., value: date)` stagger 애니메이션과 `withAnimation { store.toggleComplete(todo) }`가 동시에 발동하면서 전체 리스트가 이상하게 움직임.

### ❌ 잘못된 패턴
```swift
ForEach(todos) { todo in
    DayTaskRow(todo: todo, onComplete: { withAnimation { store.toggleComplete(todo) } })
        .animation(.spring().delay(Double(index) * 0.06), value: date)  // date 변경 시 stagger
}
```
- `date`가 안 바뀌어도 store 변경으로 body가 재평가되면서 stagger가 불필요하게 발동

### ✅ 올바른 패턴
```swift
ForEach(todos) { todo in
    DayTaskRow(todo: todo, onComplete: {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            store.toggleComplete(todo)
        }
    })
    .transition(.asymmetric(
        insertion: .scale(scale: 0.95).combined(with: .opacity),
        removal: .scale(scale: 0.95).combined(with: .opacity)
    ))
    // stagger .animation 제거 — 날짜 변경 시 애니메이션은 .id(date)로 처리
}
```

### 핵심 원칙
- `.animation(value:)`는 해당 value가 변경될 때만 발동해야 하지만, SwiftUI body 재평가 시 의도치 않게 발동될 수 있음
- 체크박스 토글 같은 데이터 변경 애니메이션은 `withAnimation`으로 명시적으로 제어
- 날짜 전환 애니메이션은 `.id(date)`로 뷰 재생성 + `.transition`으로 처리
- 두 종류의 애니메이션을 같은 뷰에 겹치지 않도록 분리

---

## 18. 스와이프 배경 노출 — ZStack + offset 패턴 주의

### 문제
스와이프 완료 기능에서 카드를 offset으로 밀면 뒤에 깔린 초록색 배경이 보임. 체크박스로 완료 처리가 가능해진 후에도 스와이프 코드가 남아있으면 상태 변경 시 초록색이 잠깐 보이는 현상 발생.

### ✅ 해결
- 체크박스 완료가 있으면 스와이프 완료는 제거 (중복 기능)
- 스와이프 제거 시 `swipeBackground`, `swipeGesture`, `@State offset` 모두 정리
- 사용하지 않는 코드가 남아있으면 예상치 못한 시각적 아티팩트 발생

---

## 19. onTapGesture vs Button — 카드 내 체크박스 터치 영역 분리

### 문제
카드 전체에 `.onTapGesture`를 걸면 내부 `Button`(체크박스)의 탭 이벤트를 가로챔. 체크박스가 안 눌리거나 간헐적으로만 동작.

### ❌ 잘못된 패턴
```swift
HStack {
    Button { toggleComplete() } label: { Circle() }  // 체크박스
    Text(title)
}
.onTapGesture { showDetail() }  // 카드 전체 탭 → 체크박스 탭을 가로챔
```

### ✅ 올바른 패턴
```swift
HStack {
    TodoCheckbox(isCompleted: false) { toggleComplete() }  // 독립 버튼

    VStack { Text(title); Text(meta) }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { showDetail() }  // 텍스트 영역에만 탭

    Spacer(minLength: 0)
}
// 카드 전체 onTapGesture 제거
```

### 핵심 원칙
- 카드 안에 버튼과 탭 제스처가 공존할 때, `onTapGesture`는 텍스트/콘텐츠 영역에만 적용
- 체크박스는 `TodoCheckbox` 공통 컴포넌트 사용 (히트 영역 44x44 보장)
- 카드 전체 `onTapGesture` 대신 영역별로 분리하여 제스처 충돌 방지
