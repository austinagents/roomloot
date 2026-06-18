import Foundation

enum DeviceID {
    private static let key = "roomloot.deviceId"

    static func current() -> String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let created = UUID().uuidString
        UserDefaults.standard.set(created, forKey: key)
        return created
    }
}

