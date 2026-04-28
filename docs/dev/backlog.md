# 📋 Todoly 백로그

## 🔴 블로커 (출시 전 필수)

| # | 항목 | 담당 | 상태 | 비고 |
|---|------|------|------|------|
| B-1 | Apple Developer 계정에서 App Store ID 등록 | 대표 | ⏳ 대기 | Bundle ID: `com.todoly.app` |
| B-2 | Firebase iOS 앱 등록 (App Store ID 필요) | 서버 | ⏳ B-1 완료 후 | `GoogleService-Info.plist` 생성 |
| B-3 | Apple Sign In 설정 (Capabilities) | iOS | ⏳ B-1 완료 후 | Developer 포털에서 Sign In with Apple 활성화 |

## 🟡 v1 출시 범위

| # | 항목 | 담당 | 상태 |
|---|------|------|------|
| V1-1 | Xcode 프로젝트 생성 + Firebase SDK 연동 | iOS | ⏳ B-2 완료 후 |
| V1-2 | Firestore 보안 규칙 배포 | 서버 | ✅ 규칙 작성 완료, 배포 대기 |
| V1-3 | Cloud Functions 배포 (휴지통 스케줄러) | 서버 | ✅ 코드 작성 완료, 배포 대기 |
| V1-4 | 전체 UI 구현 (10개 화면) | iOS | 🔧 코드 작성 완료 |
| V1-5 | 캘린더 뷰 구현 (CalendarView) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-6 | 디자인 개선 (파스텔 컬러, .rounded 서체, 애니메이션) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-7 | 캘린더 완료 체크 기능 (체크박스 탭, 스와이프 제거) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-8 | 완료 시간 기록 표시 (completedAt "오전 8:00 완료" 형식) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-9 | 캘린더 완료 항목 UI 통일 (DayTaskRow 통일 구조, 투명도 0.55) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-10 | TodoCheckbox 공통 컴포넌트 통일 (할일 탭 + 캘린더) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-11 | 카테고리 아이콘 확장 (10개 → 48개, 6그룹) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-12 | 마감일 기본값 정책 변경 (Quick Add/AddTaskSheet dueDate nil) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-13 | 캘린더 "날짜 미지정" 섹션 (B안, 접이식) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-14 | 캘린더 완료 항목 표시 정책 (dueDate/completedAt 기준) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-15 | 하단 탭바 Liquid Glass (iOS 26+ glassEffect) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-16 | 최소 지원 iOS 18 (deploymentTarget 17→18) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-17 | Privacy Info.plist 추가 (Camera, PhotoLibrary, Notifications) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-18 | 런치스크린 (UILaunchScreen plist 기반, 스토리보드 미사용) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-19 | UI 텍스트 정리 (헤더·섹션 라벨 한국어화, 이모지 제거) | iOS | ⏳ 스펙 완료, 구현 대기 |
| V1-20 | 검색 화면 개선 (검색바 상단 이동, 네비 헤더, 레이아웃 정렬, debounce 최적화) | iOS | ✅ 구현 완료 |
| V1-21 | 검색 결과 체크박스 동작 (store 변경 시 검색 결과 즉시 갱신) | iOS | ✅ 구현 완료 |
| V1-22 | 완료됨 섹션 터치 버그 수정 (헤더 탭 시 첫 아이템 상태 변경 방지) | iOS | ✅ 수정 완료 |
| V1-23 | 완료됨 섹션 여백 개선 (미완료 섹션/탭바와의 간격 확보) | iOS | ✅ 수정 완료 |
| V1-24 | TaskDetail 메모 텍스트 색상 수정 (foregroundColor 명시) | iOS | ✅ 수정 완료 |
| V1-25 | Placeholder 색상 개선 (prompt 파라미터로 txt2 색상 적용) | iOS | ✅ 수정 완료 |
| V1-26 | 시간 피커 1분 단위 + 텍스트 가시성 수정 | iOS | ✅ 수정 완료 |
| V1-27 | iOS 26 Liquid Glass 탭바만 적용 (toolbar → 커스텀 헤더 교체) | iOS | ✅ 수정 완료 |
| V1-28 | 알람 기능 (커스텀 사운드 + 풀스크린 AlarmView + 진동) | iOS | ✅ 구현 완료 |
| V1-29 | Live Activity (잠금화면 + Dynamic Island 알람 표시) | iOS | ✅ 구현 완료 |
| V1-30 | 탭 전환 깜빡임 수정 (opacity 패턴 + 애니메이션 전파 차단) | iOS | ✅ 수정 완료 |
| V1-31 | 로컬 데이터 영속화 (UserDefaults + Codable) | iOS | ✅ 구현 완료 |
| V1-32 | 알림/알람 유닛 테스트 (NotificationServiceTests, TodoAlarmAttributesTests) | iOS | ✅ 32개 테스트 통과 |
| V1-33 | 개발자 테스트 | 전체 | ⏳ |
| V1-34 | QA | QA | ⏳ |
| V1-35 | 아키텍처 리팩토링 (플랫→레이어드+Feature 기반, 순수함수 분리, Protocol DI, Preview 필수) | iOS | ✅ 완료 |
| V1-36 | Tuist Project.swift 모듈화 (레이어별 sources glob) | iOS | ✅ 완료 |
| V1-37 | 스티어링 규칙 업데이트 (code-quality-rules, project-architecture) | 전체 | ✅ 완료 |
| V1-38 | 할일 탭 오늘 필터 (오늘 할일만 노출, 오늘 완료만 표시) | iOS | ✅ 구현 완료 |
| V1-39 | 연속 할일 (기간 할일) 도입 (startDate~endDate, dailyCompletions) | iOS | ✅ 구현 완료 |
| V1-40 | 연속 할일 날짜별 완료 추적 (4/2 완료해도 4/3 미완료 재등장) | iOS | ✅ 구현 완료 |

## 🟢 v1.1 (출시 후 업데이트)

| # | 항목 |
|---|------|
| V1.1-1 | 온보딩 슬라이드 (3장) |
| V1.1-2 | 필터/정렬 바텀시트 |
| V1.1-3 | 설정 화면 (다크모드, 알림, 계정) |
| V1.1-4 | 다크모드 디자인 |
| V1.1-5 | FCM 서버 푸시 알림 |
| V1.1-6 | 메인 리스트 "오늘 마감" 요약 카드 (캘린더 탭 유도) |
| V1.1-7 | 할 일 추가 시트 캘린더 미니 프리뷰 (일정 충돌 표시) |
| V1.1-8 | 완료 섹션 "이번 주 완료" 통계 표시 |
