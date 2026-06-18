import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.charcoal, .forest, .leather], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 58))
                            .foregroundStyle(Color.agedGold)
                        Text("RoomLoot")
                            .font(.system(size: 44, weight: .black, design: .serif))
                            .foregroundStyle(Color.parchment)
                        Text("Find lost treasures around the real world.")
                            .font(.headline)
                            .foregroundStyle(Color.parchment.opacity(0.82))
                            .multilineTextAlignment(.center)
                    }

                    if let user = appState.user {
                        HStack {
                            StatPill(title: "Coins", value: "\(user.coins)")
                            StatPill(title: "Gems", value: "\(user.gems ?? 0)")
                            StatPill(title: "Level", value: "\(user.level)")
                        }
                    }

                    VStack(spacing: 14) {
                        NavigationLink {
                            MapGameView()
                        } label: {
                            Label("Start Hunt", systemImage: "map.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryAdventureButton())

                        NavigationLink {
                            InventoryView()
                        } label: {
                            Label("Inventory", systemImage: "shippingbox.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryAdventureButton())

                        NavigationLink {
                            ProfileView()
                        } label: {
                            Label("Profile", systemImage: "person.crop.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryAdventureButton())
                    }
                    Spacer()
                }
                .padding(24)
            }
            .alert("RoomLoot", isPresented: Binding(
                get: { appState.errorMessage != nil },
                set: { if !$0 { appState.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { appState.errorMessage = nil }
            } message: {
                Text(appState.errorMessage ?? "")
            }
        }
    }
}

struct PrimaryAdventureButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(Color.charcoal)
            .padding()
            .background(Color.agedGold.opacity(configuration.isPressed ? 0.75 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SecondaryAdventureButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.parchment)
            .padding()
            .background(Color.charcoal.opacity(configuration.isPressed ? 0.55 : 0.78))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brass.opacity(0.7)))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

