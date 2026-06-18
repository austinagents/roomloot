import SwiftUI
import CoreLocation

struct TreasureDetailView: View {
    let treasure: Treasure
    let currentLocation: CLLocation?
    let onStart: () -> Void

    private var distance: Double {
        guard let currentLocation else { return treasure.distanceMeters }
        return currentLocation.distance(from: CLLocation(latitude: treasure.lat, longitude: treasure.lng))
    }

    var body: some View {
        ZStack {
            Color.charcoal.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.agedGold)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)

                Text(treasure.artifactName)
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(Color.parchment)
                RarityBadge(rarity: treasure.rarity)
                Text(treasure.artifactDescription)
                    .font(.body)
                    .foregroundStyle(Color.parchment.opacity(0.84))
                Text("\(Int(distance)) meters away")
                    .font(.headline)
                    .foregroundStyle(Color.agedGold)
                Text("+\(treasure.coinValue) coins  +\(treasure.xpValue) XP")
                    .font(.headline)
                    .foregroundStyle(Color.parchment)
                Spacer()
                Button("Start AR Hunt", action: onStart)
                    .buttonStyle(PrimaryAdventureButton())
                    .disabled(distance > 25)
                    .opacity(distance > 25 ? 0.65 : 1)
            }
            .padding(24)
        }
    }
}

