import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            LinearGradient(colors: [.charcoal, .forest], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 74))
                    .foregroundStyle(Color.agedGold)
                Text(appState.user?.username ?? "Explorer")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(Color.parchment)

                HStack {
                    StatPill(title: "Level", value: "\(appState.user?.level ?? 1)")
                    StatPill(title: "Coins", value: "\(appState.user?.coins ?? 0)")
                    StatPill(title: "XP", value: "\(appState.user?.xp ?? 0)")
                }

                Text("\(appState.recentCollections.count) recent collections")
                    .font(.headline)
                    .foregroundStyle(Color.parchment.opacity(0.8))
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Profile")
        .task { await appState.refreshPlayer() }
    }
}

