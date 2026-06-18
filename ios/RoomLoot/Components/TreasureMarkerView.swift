import SwiftUI

struct TreasureMarkerView: View {
    let treasure: Treasure
    let selected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(treasure.rarity.color)
                    .frame(width: selected ? 42 : 34, height: selected ? 42 : 34)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                Image(systemName: "shippingbox.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: selected ? 19 : 16, weight: .bold))
            }
            Triangle()
                .fill(treasure.rarity.color)
                .frame(width: 12, height: 8)
                .rotationEffect(.degrees(180))
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

