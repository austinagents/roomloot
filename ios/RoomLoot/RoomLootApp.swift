import SwiftUI

@main
struct RoomLootApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}

