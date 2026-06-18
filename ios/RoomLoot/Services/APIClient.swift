import Foundation

enum APIClientError: LocalizedError {
    case invalidBaseURL
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "Set your deployed backend URL in AppConfig.swift."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .server(let message):
            return message
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        encoder = JSONEncoder()
    }

    func anonymousAuth(deviceId: String) async throws -> AuthResponse {
        try await post(path: "/api/auth/anonymous", body: ["deviceId": deviceId])
    }

    func getPlayer(userId: String) async throws -> PlayerResponse {
        try await get(path: "/api/player/me", query: ["userId": userId])
    }

    func updateLocation(userId: String, lat: Double, lng: Double, accuracy: Double?, speed: Double?, heading: Double?) async throws {
        let body: [String: EncodableValue] = [
            "userId": .string(userId),
            "lat": .double(lat),
            "lng": .double(lng),
            "accuracyMeters": .optionalDouble(accuracy),
            "speedMps": .optionalDouble(speed),
            "headingDegrees": .optionalDouble(heading)
        ]
        let _: SuccessResponse = try await post(path: "/api/location/update", body: body)
    }

    func getNearbyTreasures(userId: String, lat: Double, lng: Double, radius: Double) async throws -> NearbyTreasuresResponse {
        try await get(path: "/api/treasures/nearby", query: [
            "userId": userId,
            "lat": String(lat),
            "lng": String(lng),
            "radius": String(radius)
        ])
    }

    func collectTreasure(userId: String, treasureId: String, lat: Double, lng: Double, accuracy: Double?) async throws -> CollectResponse {
        let body: [String: EncodableValue] = [
            "userId": .string(userId),
            "treasureId": .string(treasureId),
            "lat": .double(lat),
            "lng": .double(lng),
            "accuracyMeters": .optionalDouble(accuracy)
        ]
        return try await post(path: "/api/treasures/collect", body: body)
    }

    func spawnNearby(lat: Double, lng: Double, radiusMeters: Double, count: Int) async throws {
        let body: [String: EncodableValue] = [
            "lat": .double(lat),
            "lng": .double(lng),
            "radiusMeters": .double(radiusMeters),
            "count": .int(count)
        ]
        let _: SpawnResponse = try await post(path: "/api/spawn/nearby", body: body)
    }

    private func get<T: Decodable>(path: String, query: [String: String]) async throws -> T {
        var components = URLComponents(url: try baseURL().appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else { throw APIClientError.invalidBaseURL }
        return try await send(URLRequest(url: url))
    }

    private func post<T: Decodable, Body: Encodable>(path: String, body: Body) async throws -> T {
        var request = URLRequest(url: try baseURL().appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await send(request)
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        #if DEBUG
        print("RoomLoot API:", request.httpMethod ?? "GET", request.url?.absoluteString ?? "")
        #endif

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIClientError.invalidResponse }

        if !(200...299).contains(http.statusCode) {
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data), let message = apiError.error {
                throw APIClientError.server(message)
            }
            throw APIClientError.server("Server error \(http.statusCode).")
        }

        return try decoder.decode(T.self, from: data)
    }

    private func baseURL() throws -> URL {
        guard AppConfig.apiBaseURL != "https://YOUR_BACKEND_URL_HERE",
              let url = URL(string: AppConfig.apiBaseURL) else {
            throw APIClientError.invalidBaseURL
        }
        return url
    }
}

private struct SuccessResponse: Codable {
    let success: Bool
}

private struct SpawnResponse: Codable {
    let spawned: Int?
}

enum EncodableValue: Encodable {
    case string(String)
    case double(Double)
    case optionalDouble(Double?)
    case int(Int)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .optionalDouble(let value):
            if let value {
                try container.encode(value)
            } else {
                try container.encodeNil()
            }
        case .int(let value):
            try container.encode(value)
        }
    }
}

