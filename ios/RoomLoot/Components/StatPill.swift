import SwiftUI

struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.parchment.opacity(0.75))
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.agedGold)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.charcoal.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension Color {
    static let charcoal = Color(red: 0.10, green: 0.09, blue: 0.08)
    static let parchment = Color(red: 0.86, green: 0.78, blue: 0.62)
    static let agedGold = Color(red: 0.75, green: 0.56, blue: 0.22)
    static let brass = Color(red: 0.62, green: 0.44, blue: 0.20)
    static let forest = Color(red: 0.12, green: 0.24, blue: 0.17)
    static let leather = Color(red: 0.29, green: 0.18, blue: 0.11)
    static let stone = Color(red: 0.34, green: 0.34, blue: 0.32)
}

