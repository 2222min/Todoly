import Foundation

final class AppState: ObservableObject {
    enum Screen { case splash, login, main }
    @Published var screen: Screen = .splash
}
