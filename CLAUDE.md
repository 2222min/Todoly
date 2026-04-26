# Claude Instructions

This project follows a 9-step AI app development methodology.

## Project Overview
Todoly is a SwiftUI-based iOS todo app built with Tuist.
- Language: Swift, Framework: SwiftUI, Build: Tuist
- Data: UserDefaults + Codable
- Notifications: UNUserNotificationCenter + Live Activity (ActivityKit)

## Architecture
Layered Architecture + Feature-based modularization.
Dependency direction (never violate):
- Features -> Domain, Core
- Data -> Domain  
- Domain depends on nothing (pure layer)
- Features never depend on each other (communicate via Store)

## Project Structure
Todoly/Todoly/
  App/              @main, AppDelegate, AppState, RootView
  Core/Components/  SoftPressStyle, TodoCheckbox, UndoToast
  Core/Extensions/  Color+Brand, Date+Badge
  Data/Store/       TodoStore (ObservableObject, side effects)
  Data/Services/    NotificationService
  Domain/Models/    Todo, TodoCategory, Priority, BadgeStyle, TodoAlarmAttributes
  Domain/Logic/     Pure functions (TodoMutationLogic, TodoFilterLogic, etc.)
  Domain/Protocols/ TodoStoring, NotificationScheduling
  Features/         Alarm, Auth, Calendar, Category, Search, Splash, Tab, TaskDetail, TaskList, Trash

## Code Quality Rules (Required)
1. Pure Functions: All business logic in Domain/Logic/ as static pure functions. Same input = same output. Store calls pure logic, applies results.
2. Single Responsibility: One file = one role. Max 300 lines. One function = one job. View = rendering, Logic = computation, Store = state management.
3. Protocol-based DI: Services define Protocol. Store depends on Protocol, not concrete type.
4. Preview Required: Every View file MUST include Preview macro.
5. TodoCheckbox: Always use Core/Components/TodoCheckbox.swift. Never inline.
6. Persistence: Models conform to Codable. Every mutation calls save().
7. New files: Run tuist generate --no-open after adding.

## SwiftUI Performance Patterns
1. Debounce: onChange + Task.sleep, NOT Just().debounce
2. Search results: Cache in @State, refresh on store changes
3. ScrollView: Never swap with if/else, swap content inside one ScrollView
4. Keyboard focus: DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
5. Tab switching: ZStack + opacity, NOT switch/case replacement
6. glassEffect: Never .interactive() on buttons
7. contentShape: Never .scale() > 1.0
8. TextEditor: Always set .foregroundColor explicitly
9. Empty state: Always .frame(maxWidth: .infinity)

## Data Flow
User -> View -> TodoStore -> Domain/Logic (pure) -> new state -> UI re-render

## 9-Step Development Flow
Step 1: Planning Draft -> docs/planning/v1_plan.md
Step 2: Planning Review (AI Multi-Persona) -> docs/planning/v1_review.md
  Usability Expert, Visibility Expert, Readability Expert. Classify: Red/Yellow.
Step 3: Planning Finalization -> docs/planning/FINAL_plan.md
Step 4: Design (Figma / Skip / Full flow)
Step 5: Design Review - UI/Visual(8yr), UX(7yr), Accessibility(4yr), Planning(3yr)
Step 6: Design Finalization -> docs/dev/dev_brief.md
Step 7: Dev Spec Discussion - Senior Architect + Server Developer -> docs/dev/dev_spec.md
Step 8: Dev Guide -> docs/dev/
Step 9: Implementation + Self-Review

## Change Management (Required)
NEVER modify code directly. Always update docs first.
1. Analyze change 2. Update planning docs 3. Update design/Figma 4. Update dev specs 5. THEN modify code

## Cost Minimization
Server cost $0/month. BaaS over custom. v1 = core features only.

## Troubleshooting Log
docs/troubleshooting/log.md records issues. Check before coding. Add entry after fixing.
