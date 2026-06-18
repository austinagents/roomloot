import SwiftUI

extension Rarity {
    var color: Color {
        switch self {
        case .common: return Color(red: 0.55, green: 0.34, blue: 0.18)
        case .uncommon: return Color(red: 0.18, green: 0.42, blue: 0.25)
        case .rare: return Color(red: 0.22, green: 0.38, blue: 0.58)
        case .epic: return Color(red: 0.45, green: 0.31, blue: 0.53)
        case .legendary: return Color(red: 0.79, green: 0.58, blue: 0.20)
        }
    }
}

struct RarityBadge: View {
    let rarity: Rarity

    var body: some View {
        Text(rarity.title)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(rarity.color)
            .clipShape(Capsule())
    }
}

