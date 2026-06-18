import SwiftUI

struct CollectionResultView: View {
    let collection: CollectedTreasure
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [.charcoal, .leather], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "seal.fill")
                    .font(.system(size: 76))
                    .foregroundStyle(Color.agedGold)
                Text("New Treasure Collected!")
                    .font(.title.weight(.black))
                    .foregroundStyle(Color.parchment)
                Text(collection.artifactName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.agedGold)
                    .multilineTextAlignment(.center)
                RarityBadge(rarity: collection.rarity)
                if let description = collection.artifactDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Color.parchment.opacity(0.82))
                        .multilineTextAlignment(.center)
                }
                HStack {
                    StatPill(title: "Coins", value: "+\(collection.coinsAwarded)")
                    StatPill(title: "XP", value: "+\(collection.xpAwarded)")
                }
                Button("Continue", action: onContinue)
                    .buttonStyle(PrimaryAdventureButton())
                    .padding(.top, 8)
            }
            .padding(24)
        }
    }
}

