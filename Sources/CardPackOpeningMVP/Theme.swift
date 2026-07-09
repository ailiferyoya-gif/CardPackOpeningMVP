import SwiftUI

extension Color {
    static let packNavy = Color(red: 15 / 255.0, green: 23 / 255.0, blue: 42 / 255.0)
    static let packNavyDeep = Color(red: 4 / 255.0, green: 9 / 255.0, blue: 23 / 255.0)
    static let packGold = Color(red: 217 / 255.0, green: 119 / 255.0, blue: 6 / 255.0)
    static let packGoldBright = Color(red: 251 / 255.0, green: 191 / 255.0, blue: 36 / 255.0)
}

extension CardRarity {
    var symbolName: String {
        switch self {
        case .normal: "circle.fill"
        case .rare: "diamond.fill"
        case .superRare: "star.fill"
        case .ultraRare: "sparkles"
        case .ultimateRare: "crown.fill"
        }
    }
}

struct CelestialBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.packNavyDeep, .packNavy, Color(red: 0.13, green: 0.05, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [.packGold.opacity(0.18), .clear],
                center: .topTrailing,
                startRadius: 8,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}
