import Foundation
import CoreLocation

struct Player: Codable, Identifiable {
    let id: String
    var username: String
    var coins: Int
    var gems: Int?
    var xp: Int
    var level: Int
}

struct Treasure: Codable, Identifiable, Hashable {
    let id: String
    let artifactName: String
    let artifactDescription: String
    let rarity: Rarity
    let coinValue: Int
    let xpValue: Int
    let lat: Double
    let lng: Double
    let distanceMeters: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

enum Rarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var title: String { rawValue.capitalized }
}

struct CollectionRecord: Codable, Identifiable {
    let id: String
    let treasureId: String?
    let artifactName: String
    let rarity: Rarity
    let coinsAwarded: Int
    let xpAwarded: Int
    let collectedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case treasureId = "treasure_id"
        case artifactName = "artifact_name"
        case rarity
        case coinsAwarded = "coins_awarded"
        case xpAwarded = "xp_awarded"
        case collectedAt = "collected_at"
    }
}

struct AuthResponse: Codable {
    let user: Player
}

struct PlayerResponse: Codable {
    let user: Player
    let recentCollections: [CollectionRecord]
}

struct NearbyTreasuresResponse: Codable {
    let treasures: [Treasure]
}

struct CollectResponse: Codable {
    let success: Bool
    let collection: CollectedTreasure?
    let user: PlayerProgress?
    let error: String?
}

struct CollectedTreasure: Codable {
    let artifactName: String
    let rarity: Rarity
    let coinsAwarded: Int
    let xpAwarded: Int
    let artifactDescription: String?
}

struct PlayerProgress: Codable {
    let coins: Int
    let xp: Int
    let level: Int
}

struct APIErrorResponse: Codable {
    let success: Bool?
    let error: String?
}

