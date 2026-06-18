import SwiftUI

struct InventoryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = "Treasures"
    private let tabs = ["Treasures", "Materials", "Items"]

    var body: some View {
        ZStack {
            Color.charcoal.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Picker("Inventory", selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                if selectedTab == "Treasures" {
                    if appState.recentCollections.isEmpty {
                        ContentUnavailableView("No treasures yet", systemImage: "shippingbox", description: Text("Start a hunt and collect your first artifact."))
                            .foregroundStyle(Color.parchment)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                                ForEach(appState.recentCollections) { item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Image(systemName: "shippingbox.fill")
                                            .font(.title)
                                            .foregroundStyle(Color.agedGold)
                                        Text(item.artifactName)
                                            .font(.headline)
                                            .foregroundStyle(Color.parchment)
                                            .lineLimit(2)
                                        RarityBadge(rarity: item.rarity)
                                        Text("+\(item.coinsAwarded) coins  +\(item.xpAwarded) XP")
                                            .font(.caption)
                                            .foregroundStyle(Color.parchment.opacity(0.74))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.leather.opacity(0.82))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("Coming later", systemImage: "backpack", description: Text("\(selectedTab) are reserved for future crafting and item systems."))
                        .foregroundStyle(Color.parchment)
                }
            }
            .padding()
        }
        .navigationTitle("Inventory")
        .task { await appState.refreshPlayer() }
    }
}

