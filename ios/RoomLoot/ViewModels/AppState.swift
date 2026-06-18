import Foundation
import CoreLocation

@MainActor
final class AppState: ObservableObject {
    @Published var user: Player?
    @Published var treasures: [Treasure] = []
    @Published var recentCollections: [CollectionRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTreasure: Treasure?
    @Published var collectionResult: CollectedTreasure?

    private let api: APIClient
    private var lastFetchLocation: CLLocation?
    private var lastFetchAt: Date?

    init(api: APIClient = .shared) {
        self.api = api
    }

    func bootstrap() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await api.anonymousAuth(deviceId: DeviceID.current())
            user = response.user
            await refreshPlayer()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshPlayer() async {
        guard let user else { return }
        do {
            let response = try await api.getPlayer(userId: user.id)
            self.user = response.user
            recentCollections = response.recentCollections
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateLocation(_ location: CLLocation) async {
        guard let user else { return }
        do {
            try await api.updateLocation(
                userId: user.id,
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                accuracy: location.horizontalAccuracy,
                speed: location.speed >= 0 ? location.speed : nil,
                heading: location.course >= 0 ? location.course : nil
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshTreasuresIfNeeded(location: CLLocation, force: Bool = false) async {
        let movedEnough = lastFetchLocation.map { $0.distance(from: location) > 25 } ?? true
        let stale = lastFetchAt.map { Date().timeIntervalSince($0) > 10 } ?? true
        guard force || movedEnough || stale else { return }
        await refreshTreasures(location: location)
    }

    func refreshTreasures(location: CLLocation) async {
        guard let user else { return }
        do {
            let response = try await api.getNearbyTreasures(
                userId: user.id,
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                radius: 500
            )
            treasures = response.treasures
            lastFetchLocation = location
            lastFetchAt = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func collect(_ treasure: Treasure, at location: CLLocation) async -> CollectResponse? {
        guard let user else { return nil }
        do {
            let response = try await api.collectTreasure(
                userId: user.id,
                treasureId: treasure.id,
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                accuracy: location.horizontalAccuracy
            )
            if response.success {
                if let progress = response.user {
                    self.user?.coins = progress.coins
                    self.user?.xp = progress.xp
                    self.user?.level = progress.level
                }
                collectionResult = response.collection
                treasures.removeAll { $0.id == treasure.id }
                await refreshPlayer()
            } else {
                errorMessage = response.error
            }
            return response
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

