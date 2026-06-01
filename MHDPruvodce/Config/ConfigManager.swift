import Foundation

final class ConfigManager {
    static let shared = ConfigManager()

    private let config: [String: Any]

    private init() {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any] else {
            fatalError("Config.plist not found. Copy Config.example.plist to Config.plist and fill in your API keys.")
        }
        config = dict
    }

    var chapsAPIKey: String {
        config["CHAPS_API_KEY"] as? String ?? ""
    }

    var chapsBaseURL: String {
        config["CHAPS_BASE_URL"] as? String ?? "https://api.idos.cz/api/v1"
    }

    var chapsAppID: String {
        config["CHAPS_APP_ID"] as? String ?? ""
    }
}
