import SwiftUI

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

    // Warm background
    static let brandBg = Color(hex: "FFF8F2")
    static let cardBg = Color(hex: "FFFFFF")
    static let softCard = Color(hex: "FFF5EE")

    // Priority
    static let priHigh = Color(hex: "FF6B6B")
    static let priMed = Color(hex: "FFAB5E")
    static let priLow = Color(hex: "5B9BF5")

    // Text
    static let txt1 = Color(hex: "2D2D2D")
    static let txt2 = Color(hex: "6B6B6B")
    static let txt3 = Color(hex: "B0B0B0")

    // Accent
    static let accent1 = Color(hex: "FF8A65")
    static let accent2 = Color(hex: "A78BFA")
    static let accent3 = Color(hex: "6DD5C8")
    static let danger = Color(hex: "FF6B6B")

    // Gradients
    static let warmGrad1 = Color(hex: "FFE0CC")
    static let warmGrad2 = Color(hex: "FFD1E8")
    static let warmGrad3 = Color(hex: "E8D5FF")
}
